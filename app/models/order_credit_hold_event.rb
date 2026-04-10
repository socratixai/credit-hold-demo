class OrderCreditHoldEvent < ApplicationRecord
  enum :event_type, {
    placed_on_hold: "placed_on_hold",
    released: "released",
    overridden: "overridden"
  }

  belongs_to :sales_order
  belongs_to :triggered_by_rule, class_name: "CreditHoldRule", foreign_key: :triggered_by_rule_id, optional: true
  belongs_to :actor, class_name: "User", foreign_key: :actor_id

  validates :event_type, :event_date, :actor_id, presence: true
  validates :override_reason, presence: true, if: -> { overridden? }
end
