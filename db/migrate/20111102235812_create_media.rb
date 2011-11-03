class CreateMedia < ActiveRecord::Migration
  def self.up
    create_table :media do |t|
      t.string :name

      t.timestamps
    end
    #add_column :record_formats, :media_id, :integer
  end

  def self.down
    #remove_column :record_formats, :media_id
    drop_table :media
  end
end