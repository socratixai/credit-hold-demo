class CreateCustomerCreditProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_credit_profiles do |t|
      t.references :customer, null: false, foreign_key: true
      t.decimal :credit_limit, precision: 10, scale: 2, default: 0
      t.boolean :credit_hold_flag, null: false, default: false
      t.integer :payment_terms_days, default: 30
      t.string :currency_code, default: "USD"
      t.date :review_date
      t.bigint :updated_by_id
      t.index :updated_by_id

      t.timestamps
    end

    add_foreign_key :customer_credit_profiles, :users, column: :updated_by_id
  end
end
