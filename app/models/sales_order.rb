class SalesOrder < ApplicationRecord
  enum :status, {
    draft: "draft",
    pending_credit_check: "pending_credit_check",
    approved: "approved",
    on_hold: "on_hold",
    released: "released",
    fulfilled: "fulfilled"
  }

  belongs_to :customer
  has_many :sales_order_lines, dependent: :destroy
  has_many :products, through: :sales_order_lines
  has_many :invoices, dependent: :destroy
  has_many :order_credit_hold_events, dependent: :destroy

  validates :order_date, :status, :total_amount, presence: true
end
