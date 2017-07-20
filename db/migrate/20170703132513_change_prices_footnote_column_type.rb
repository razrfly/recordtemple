class ChangePricesFootnoteColumnType < ActiveRecord::Migration
  def self.up
    update_view :simple_searches, version: 2, revert_to_version: 1
    change_column :prices, :footnote, :text
    update_view :simple_searches, version: 3, revert_to_version: 2
  end

  def self.down
    update_view :simple_searches, version: 3, revert_to_version: 2
    change_column :prices, :footnote, :string
    update_view :simple_searches, version: 2, revert_to_version: 1
  end
end
