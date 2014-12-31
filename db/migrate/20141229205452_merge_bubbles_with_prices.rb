class MergeBubblesWithPrices < ActiveRecord::Migration
  def up
    execute "UPDATE prices SET pricehigh = (SELECT high FROM bubbles WHERE prices.id = bubbles.price_id ORDER BY bubbles.updated_at DESC LIMIT 1)"
    execute "UPDATE prices SET pricelow = (SELECT low FROM bubbles WHERE prices.id = bubbles.price_id ORDER BY bubbles.updated_at DESC LIMIT 1)"
    rename_column :prices, :pricehigh, :price_high
    rename_column :prices, :pricelow, :price_low
    drop_table :bubbles
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
