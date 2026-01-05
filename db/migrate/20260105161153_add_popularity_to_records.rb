class AddPopularityToRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :records, :popularity_score, :integer, default: 0, null: false
    add_column :records, :images_count, :integer, default: 0, null: false
    add_column :records, :songs_count, :integer, default: 0, null: false

    add_index :records, :popularity_score
  end
end
