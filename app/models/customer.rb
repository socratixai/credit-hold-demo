class Customer < ApplicationRecord
  enum :segment, { sme: "sme", enterprise: "enterprise", strategic: "strategic" }

  has_one :customer_credit_profile, dependent: :destroy
  has_many :sales_orders, dependent: :destroy
  has_many :invoices, through: :sales_orders
  has_one :crm_account, dependent: :destroy
  has_many :customer_interactions, dependent: :destroy

  validates :name, presence: true
end
