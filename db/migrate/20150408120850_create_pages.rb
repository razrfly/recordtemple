class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :content
      t.references :user, index: true
      t.integer :position
      t.string :cover
      t.string :slug

      t.timestamps
    end
  end
end
