class CreateRecordTypes < ActiveRecord::Migration
  def self.up
    create_table :record_types do |t|
      t.string :name

      t.timestamps
    end
    add_column :record_formats, :record_type_id, :integer
  end

  def self.down
    remove_column :record_formats, :record_type_id
    drop_table :record_types
  end
end