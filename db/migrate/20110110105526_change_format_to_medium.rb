class ChangeFormatToMedium < ActiveRecord::Migration
  def self.up
    rename_column :prices, :format, :media_type
  end

  def self.down
    rename_column :prices, :media_type, :format
  end
end
