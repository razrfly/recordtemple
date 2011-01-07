class FullTextSearch1294394663 < ActiveRecord::Migration
  def self.up
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS artists_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      CREATE index artists_fts_idx
      ON artists
      USING gin((to_tsvector('english', coalesce("artists"."name", ''))))
    eosql
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS labels_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      CREATE index labels_fts_idx
      ON labels
      USING gin((to_tsvector('english', coalesce("labels"."name", ''))))
    eosql
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS prices_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      CREATE index prices_fts_idx
      ON prices
      USING gin((to_tsvector('english', coalesce("prices"."detail", '') || ' ' || coalesce("prices"."footnote", ''))))
    eosql
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS records_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      CREATE index records_fts_idx
      ON records
      USING gin((to_tsvector('english', coalesce("records"."comment", ''))))
    eosql
  end

  def self.down
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS artists_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS labels_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS prices_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS records_fts_idx
    eosql
  end
end
