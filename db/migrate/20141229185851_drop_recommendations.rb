class DropRecommendations < ActiveRecord::Migration
  def up
    drop_table :recommendations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
