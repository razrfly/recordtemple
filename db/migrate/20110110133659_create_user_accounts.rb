class CreateUserAccounts < ActiveRecord::Migration
  def self.up
    create_table :user_accounts do |t|
      t.string :provider
      t.string :auth_type
      t.string :key
      t.string :secret
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_accounts
  end
end
