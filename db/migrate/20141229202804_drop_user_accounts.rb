class DropUserAccounts < ActiveRecord::Migration
  def up
    drop_table :user_accounts
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
