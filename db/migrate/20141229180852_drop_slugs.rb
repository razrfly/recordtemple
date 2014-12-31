class DropSlugs < ActiveRecord::Migration
  def up
    drop_table :slugs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
