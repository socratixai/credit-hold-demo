class CreateCrmAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :crm_accounts do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :account_potential
      t.decimal :estimated_annual_value, precision: 10, scale: 2
      t.bigint :relationship_owner_id
      t.text :notes

      t.timestamps
    end

    add_index :crm_accounts, :relationship_owner_id
    add_foreign_key :crm_accounts, :users, column: :relationship_owner_id
  end
end
