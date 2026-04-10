class Invoice < ApplicationRecord
  enum :status, {
    open: "open",
    partially_paid: "partially_paid",
    paid: "paid",
    overdue: "overdue",
    disputed: "disputed"
  }

  belongs_to :sales_order

  validates :invoice_date, :due_date, :total_amount, :status, presence: true
end
