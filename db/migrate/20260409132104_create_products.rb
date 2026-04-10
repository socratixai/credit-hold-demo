class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.decimal :unit_price
      t.string :currency_code

      t.timestamps
    end
  end
end
