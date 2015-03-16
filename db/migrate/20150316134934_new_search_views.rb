class NewSearchViews < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute <<-SQL
    DROP VIEW searches;
    CREATE VIEW searches AS
      SELECT artists.id AS searchable_id, artists.name AS term,
              CAST ('Artist' AS varchar) AS searchable_type
      FROM artists
      UNION
      SELECT labels.id AS searchable_id, labels.name AS term,
              CAST ('Label' AS varchar) AS searchable_type
      FROM labels
      UNION
      SELECT genres.id AS searchable_id, genres.name AS term,
              CAST ('Genre' AS varchar) AS searchable_type
      FROM genres
      UNION
      SELECT record_types.id AS searchable_id, record_types.name AS term,
              CAST ('RecordType' AS varchar) AS searchable_type
      FROM record_types
    SQL
  end

  def self.down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP VIEW searches
    SQL
  end
end
