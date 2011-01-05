class CreateSearches < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute <<-SQL
        CREATE VIEW searches AS
          SELECT  artists.id AS searchable_id, artists.name AS term, 
                  CAST ('Artist' AS varchar) AS searchable_type 
          FROM artists
          INNER JOIN records
          ON artists.id=records.artist_id
          UNION 
          SELECT  labels.id AS searchable_id, labels.name AS term, 
                  CAST ('Label' AS varchar) AS searchable_type 
          FROM labels
          INNER JOIN records
          ON labels.id=records.label_id
          UNION 
          SELECT  songs.id AS searchable_id, songs.title AS term, 
                  CAST ('Song' AS varchar) AS searchable_type 
          FROM songs
          UNION 
          SELECT  records.id AS searchable_id, records.comment AS term, 
                  CAST ('Record' AS varchar) AS searchable_type 
          FROM records
          UNION 
          SELECT  prices.id AS searchable_id, prices.detail||prices.footnote AS term, 
                  CAST ('Price' AS varchar) AS searchable_type 
          FROM prices
          INNER JOIN records
          ON prices.id=records.price_id
    SQL
  end

  def self.down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP VIEW searches
    SQL
  end
end
