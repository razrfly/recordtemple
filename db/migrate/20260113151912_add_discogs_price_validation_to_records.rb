class AddDiscogsPriceValidationToRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :records, :discogs_price_validation, :string
  end
end
