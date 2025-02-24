class Subscription < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  # validates :stripe_subscription_id, presence: true
  validates :stripe_customer_id, presence: true
  validates :stripe_payment_status, presence: true
  validates :stripe_customer_event_id, presence: true
  # validates :stripe_checkout_evet_id, presence: true

end
