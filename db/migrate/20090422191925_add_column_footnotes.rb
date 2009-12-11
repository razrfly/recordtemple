class AddColumnFootnotes < ActiveRecord::Migration
  def self.up
    add_column :prices, :footnote, :string
  end

  def self.down
    drop_column :prices, :footnote
  end
end
