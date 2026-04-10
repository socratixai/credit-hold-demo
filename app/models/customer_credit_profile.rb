class CustomerCreditProfile < ApplicationRecord
  belongs_to :customer
  belongs_to :updated_by, class_name: "User", foreign_key: :updated_by_id, optional: true

  validates :credit_limit, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
