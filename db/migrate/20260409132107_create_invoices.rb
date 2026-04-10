class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :sales_order, null: false, foreign_key: true
      t.date :invoice_date, null: false
      t.date :due_date, null: false
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.decimal :paid_amount, precision: 10, scale: 2, default: 0
      t.string :status, null: false, default: "open"
      t.string :currency_code, default: "USD"

      t.timestamps
    end

    add_index :invoices, [ :sales_order_id, :status ]
  end
end
