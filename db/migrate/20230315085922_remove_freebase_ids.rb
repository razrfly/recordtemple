class RemoveFreebaseIds < ActiveRecord::Migration[7.0]
  def change
    drop_table :pages
    remove_column :artists, :freebase_id
    remove_column :labels, :freebase_id
    remove_column :prices, :freebase_id
  end
end
