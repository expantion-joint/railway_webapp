class WebhooksController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      logger.error "Invalid payload: #{e.message}"
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      logger.error "Invalid signature: #{e.message}"
      return head :bad_request
    end

    case event.type
    when 'checkout.session.completed'
      handle_checkout_session_completed(event)
    when 'customer.created'
      handle_customer_created(event)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event)
    when 'invoice.payment_failed'
      handle_payment_failed(event)
    else
      logger.warn "Unhandled event type: #{event.type}"
    end
    head :ok
  end

  private

  def handle_checkout_session_completed(event)
    session = event.data.object
    subscription = Subscription.find_by(stripe_customer_id: session.customer)
    if subscription
      if event.id != subscription.stripe_checkout_event_id
        subscription.update(
          stripe_subscription_id: session.id,
          stripe_payment_status: session.payment_status,
          stripe_checkout_event_id: event.id
        )
        logger.info "######### Subscription updated successfully for #{subscription.user_id}"
      end
    else
      logger.error "######### Failed to find subscription for customer_id: #{session.customer}"
    end
  end

  def handle_customer_created(event)
    session = event.data.object
    user = User.find_by(email: session.email)
    subscription = Subscription.find_by(user_id: user.id)
    if subscription && event.id == subscription.stripe_customer_event_id
    else
      if user
        Subscription.create(
          user_id: user.id,
          stripe_customer_id: session.id,
          stripe_payment_status: 'customer_created',
          stripe_customer_event_id: event.id
        )
        logger.info "######### Customer created and subscription initialized for #{user.id}"
      else
        logger.error "######### Failed to find user with email: #{session.email}"
      end
    end
  end

  def handle_subscription_deleted(event)
    session = event.data.object
    subscription = Subscription.find_by(stripe_customer_id: session.customer)
    if subscription
      if event.id != subscription.stripe_subscription_deleted_event_id
        subscription.update(
          stripe_payment_status: 'canceled',
          stripe_subscription_deleted_event_id: event.id
        )
        logger.info "######### Subscription deleted successfully for #{subscription.user_id}"
      end
    else
      logger.error "######### Failed to delete subscription for customer_id: #{session.customer}"
    end
  end

  def handle_payment_failed(event)
    session = event.data.object
    subscription = Subscription.find_by(stripe_customer_id: session.customer)
    if subscription
      if subscription.stripe_payment_status != 'customer_created' # customer_createdの場合、メールを送信しない
        if event.id != subscription.stripe_payment_failed_event_id
          subscription.update(stripe_payment_failed_event_id: event.id)
          begin
            user = subscription.user  # 関連するユーザーを取得
            StripeMailer.payment_failed_mail(user, session).deliver_now
            logger.info "######### Send email successfully for user ID: #{user.id}"
          rescue => e
            logger.error "######### An error occurred while sending email: #{e.message}"
          end
        end
      else
        logger.error "######### Don't send email because stripe_payment_status is customer_created"
      end
    else
      logger.error "######### Failed to find subscription for customer_id: #{session.customer}"
    end
  end
  

  # --------------------------------
  # stripe_payment_status
  # no_payment_required: The payment is delayed to a future date, or the Checkout Session is in setup mode and doesn’t require a payment at this time.
  # paid: The payment funds are available in your account.
  # unpaid: The payment funds are not yet available in your account.
  # --------------------------------

end
