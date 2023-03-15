class AddForeignKeys < ActiveRecord::Migration[7.0]
  def change
    # prices
    add_foreign_key :prices, :artists
    add_foreign_key :prices, :labels
    add_foreign_key :prices, :record_formats
    add_foreign_key :prices, :users
    # record formats
    add_foreign_key :record_formats, :record_types
    # records
    add_foreign_key :records, :artists
    add_foreign_key :records, :genres
    add_foreign_key :records, :labels
    add_foreign_key :records, :record_formats
    add_foreign_key :records, :users
    add_foreign_key :records, :prices
    
  end
end
