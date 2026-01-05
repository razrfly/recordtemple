class EnableUnaccentExtension < ActiveRecord::Migration[8.1]
  def change
    enable_extension "unaccent"
    enable_extension "pg_trgm"
  end
end
