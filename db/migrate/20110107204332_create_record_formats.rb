class CreateRecordFormats < ActiveRecord::Migration
  def self.up
    add_column :prices, :record_format_id, :integer
    create_table :record_formats do |t|
      t.string :name

      t.timestamps
    end
    
  end

  def self.down
    remove_column :prices, :record_format_id
    drop_table :record_formats
  end
end
