require 'stripe'
Stripe.api_key = ENV['STRIPE_SECRET_KEY']
# Stripe.api_version = '2024-09-30.acacia'
Stripe.api_version = '2023-08-16'
