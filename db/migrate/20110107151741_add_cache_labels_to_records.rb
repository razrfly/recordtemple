class AddCacheLabelsToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :cached_label, :string
    #Record.all.each do |r|
    #  r.update_attribute :cached_label, r.label.name
    #end
  end

  def self.down
    remove_column :records, :cached_label
  end
end
