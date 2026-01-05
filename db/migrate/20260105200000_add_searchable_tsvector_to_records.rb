class AddSearchableTsvectorToRecords < ActiveRecord::Migration[8.1]
  def up
    # Add tsvector column for full-text search
    add_column :records, :searchable, :tsvector

    # Create GIN index for fast full-text search
    add_index :records, :searchable, using: :gin, name: "index_records_on_searchable"

    # Populate the searchable column with data from records and associations
    # Using PostgreSQL UPDATE...FROM syntax with subqueries for optional price data
    execute <<-SQL
      UPDATE records
      SET searchable = (
        setweight(to_tsvector('english', coalesce(records.cached_artist, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(a.name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(records.cached_label, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(l.name, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(g.name, '')), 'C') ||
        setweight(to_tsvector('english', coalesce(rf.name, '')), 'C') ||
        setweight(to_tsvector('english', coalesce(records.comment, '')), 'C') ||
        setweight(to_tsvector('english', coalesce((SELECT detail FROM prices WHERE id = records.price_id), '')), 'D') ||
        setweight(to_tsvector('english', coalesce((SELECT footnote FROM prices WHERE id = records.price_id), '')), 'D') ||
        setweight(to_tsvector('english', coalesce((SELECT yearbegin::text FROM prices WHERE id = records.price_id), '')), 'D') ||
        setweight(to_tsvector('english', coalesce((SELECT yearend::text FROM prices WHERE id = records.price_id), '')), 'D')
      )
      FROM artists a, labels l, genres g, record_formats rf
      WHERE records.artist_id = a.id
        AND records.label_id = l.id
        AND records.genre_id = g.id
        AND records.record_format_id = rf.id
    SQL

    # Create trigger function to auto-update searchable column
    execute <<-SQL
      CREATE OR REPLACE FUNCTION records_searchable_trigger() RETURNS trigger AS $$
      DECLARE
        artist_name text;
        label_name text;
        genre_name text;
        format_name text;
        price_detail text;
        price_footnote text;
        price_yearbegin text;
        price_yearend text;
      BEGIN
        -- Get associated data
        SELECT name INTO artist_name FROM artists WHERE id = NEW.artist_id;
        SELECT name INTO label_name FROM labels WHERE id = NEW.label_id;
        SELECT name INTO genre_name FROM genres WHERE id = NEW.genre_id;
        SELECT name INTO format_name FROM record_formats WHERE id = NEW.record_format_id;

        IF NEW.price_id IS NOT NULL THEN
          SELECT detail, footnote, yearbegin::text, yearend::text
          INTO price_detail, price_footnote, price_yearbegin, price_yearend
          FROM prices WHERE id = NEW.price_id;
        END IF;

        NEW.searchable :=
          setweight(to_tsvector('english', coalesce(NEW.cached_artist, '')), 'A') ||
          setweight(to_tsvector('english', coalesce(artist_name, '')), 'A') ||
          setweight(to_tsvector('english', coalesce(NEW.cached_label, '')), 'B') ||
          setweight(to_tsvector('english', coalesce(label_name, '')), 'B') ||
          setweight(to_tsvector('english', coalesce(genre_name, '')), 'C') ||
          setweight(to_tsvector('english', coalesce(format_name, '')), 'C') ||
          setweight(to_tsvector('english', coalesce(NEW.comment, '')), 'C') ||
          setweight(to_tsvector('english', coalesce(price_detail, '')), 'D') ||
          setweight(to_tsvector('english', coalesce(price_footnote, '')), 'D') ||
          setweight(to_tsvector('english', coalesce(price_yearbegin, '')), 'D') ||
          setweight(to_tsvector('english', coalesce(price_yearend, '')), 'D');

        RETURN NEW;
      END
      $$ LANGUAGE plpgsql;
    SQL

    # Create trigger on records table
    execute <<-SQL
      CREATE TRIGGER records_searchable_update
      BEFORE INSERT OR UPDATE ON records
      FOR EACH ROW EXECUTE FUNCTION records_searchable_trigger();
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS records_searchable_update ON records"
    execute "DROP FUNCTION IF EXISTS records_searchable_trigger()"
    remove_index :records, name: "index_records_on_searchable"
    remove_column :records, :searchable
  end
end
