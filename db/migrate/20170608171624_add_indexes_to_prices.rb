class AddIndexesToPrices < ActiveRecord::Migration
  def self.up
    execute <<-SQL.strip
      DROP INDEX IF EXISTS prices_fts_idx
    SQL

    execute <<-SQL.strip
      CREATE INDEX index_prices_on_cached_artist_trigram
      ON prices
      USING gin (cached_artist gin_trgm_ops);
    SQL

    execute <<-SQL.strip
      CREATE INDEX index_prices_on_media_type_trigram
      ON prices
      USING gin (media_type gin_trgm_ops);
    SQL

    execute <<-SQL.strip
      CREATE INDEX index_prices_on_cached_label_trigram
      ON prices
      USING gin (cached_label gin_trgm_ops);
    SQL

    execute <<-SQL.strip
      CREATE INDEX index_prices_on_detail_trigram
      ON prices
      USING gin (detail gin_trgm_ops);
    SQL
  end

  def self.down
    execute <<-SQL.strip
      DROP INDEX IF EXISTS index_prices_on_cached_artist_trigram
    SQL

    execute <<-SQL.strip
      DROP INDEX IF EXISTS index_prices_on_media_type_trigram
    SQL

    execute <<-SQL.strip
      DROP INDEX IF EXISTS index_prices_on_cached_label_trigram
    SQL

    execute <<-SQL.strip
      DROP INDEX IF EXISTS index_prices_on_detail_trigram
    SQL
  end
end
