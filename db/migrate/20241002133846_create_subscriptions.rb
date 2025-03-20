class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_subscription_id
      t.string :stripe_customer_id
      t.string :stripe_payment_status
      t.string :stripe_customer_event_id
      t.string :stripe_checkout_event_id
      t.string :stripe_subscription_deleted_event_id
      t.string :stripe_payment_failed_event_id

      t.timestamps
    end
  end
end
