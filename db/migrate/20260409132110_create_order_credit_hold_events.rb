class CreateOrderCreditHoldEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :order_credit_hold_events do |t|
      t.references :sales_order, null: false, foreign_key: true
      t.bigint :triggered_by_rule_id
      t.string :event_type, null: false
      t.datetime :event_date, null: false
      t.bigint :actor_id, null: false
      t.text :override_reason
      t.jsonb :credit_snapshot, default: {}

      t.timestamps
    end

    add_index :order_credit_hold_events, :triggered_by_rule_id
    add_index :order_credit_hold_events, :actor_id
    add_foreign_key :order_credit_hold_events, :credit_hold_rules, column: :triggered_by_rule_id
    add_foreign_key :order_credit_hold_events, :users, column: :actor_id
  end
end
