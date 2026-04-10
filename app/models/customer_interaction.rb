class CustomerInteraction < ApplicationRecord
  enum :interaction_type, {
    visit: "visit",
    call: "call",
    email: "email",
    meeting: "meeting",
    complaint: "complaint"
  }

  enum :sentiment, {
    positive: "positive",
    neutral: "neutral",
    negative: "negative"
  }

  belongs_to :customer
  belongs_to :actor, class_name: "User", foreign_key: :actor_id

  validates :interaction_type, :interaction_date, :actor_id, presence: true
end
