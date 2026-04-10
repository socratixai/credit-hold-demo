class CreateCreditHoldRules < ActiveRecord::Migration[8.1]
  def change
    create_table :credit_hold_rules do |t|
      t.string :name, null: false
      t.string :rule_type, null: false
      t.decimal :threshold_value, precision: 10, scale: 2
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end
