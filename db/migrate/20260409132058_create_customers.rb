class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :tax_id
      t.string :segment
      t.string :billing_street
      t.string :billing_city
      t.string :billing_country

      t.timestamps
    end
  end
end
