class ChangePricesFootnoteColumnType < ActiveRecord::Migration
  def self.up
    update_view :simple_searches, version: 2, revert_to_version: 1
    change_column :prices, :footnote, :text
  end

  def self.down
    change_column :prices, :footnote, :string
    update_view :simple_searches, version: 3, revert_to_version: 2
  end
end
