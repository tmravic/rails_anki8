class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.float :price
      t.boolean :active, default: false
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
