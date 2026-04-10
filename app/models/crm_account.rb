class CrmAccount < ApplicationRecord
  enum :account_potential, {
    low: "low",
    medium: "medium",
    high: "high",
    strategic: "strategic"
  }

  belongs_to :customer
  belongs_to :relationship_owner, class_name: "User", foreign_key: :relationship_owner_id, optional: true

  validates :account_potential, presence: true
end
