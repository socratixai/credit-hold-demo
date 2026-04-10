class User < ApplicationRecord
  enum :role, { credit_manager: "credit_manager", sales_rep: "sales_rep", admin: "admin" }

  has_many :customer_credit_profiles, foreign_key: :updated_by_id
  has_many :order_credit_hold_events, foreign_key: :actor_id
  has_many :crm_accounts, foreign_key: :relationship_owner_id
  has_many :customer_interactions, foreign_key: :actor_id

  validates :name, :email, :role, presence: true
end
