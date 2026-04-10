class CreateCustomerInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_interactions do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :interaction_type, null: false
      t.date :interaction_date, null: false
      t.bigint :actor_id, null: false
      t.text :summary
      t.string :sentiment

      t.timestamps
    end

    add_index :customer_interactions, :actor_id
    add_foreign_key :customer_interactions, :users, column: :actor_id
  end
end
