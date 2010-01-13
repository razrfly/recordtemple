class CreateRecommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.string :email
      t.text :message
      t.string :token
      t.date :expiration
      t.references :record
      t.timestamps
    end
  end
  
  def self.down
    drop_table :recommendations
  end
end
