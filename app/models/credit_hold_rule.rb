class CreditHoldRule < ApplicationRecord
  enum :rule_type, {
    overdue_amount: "overdue_amount",
    credit_utilization_pct: "credit_utilization_pct",
    overdue_days: "overdue_days",
    manual: "manual"
  }

  has_many :order_credit_hold_events, foreign_key: :triggered_by_rule_id

  validates :name, :rule_type, presence: true
  validates :threshold_value, presence: true, unless: -> { manual? }
end
