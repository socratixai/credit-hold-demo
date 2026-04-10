class CreateSalesOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.date :order_date, null: false
      t.string :status, null: false, default: "draft"
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.string :currency_code, default: "USD"

      t.timestamps
    end

    add_index :sales_orders, [ :customer_id, :status ]
  end
end
