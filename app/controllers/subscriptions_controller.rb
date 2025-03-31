class SubscriptionsController < ApplicationController

  require 'stripe'
  before_action :authenticate_user!

  # サブスクリプションの作成
  def new
    subscription = Subscription.find_by(user_id: current_user.id)
    @session = Stripe::Checkout::Session.create(
      customer: subscription.stripe_customer_id,
      mode: 'subscription', # サブスク
      payment_method_types: ['card'], # クレジットカード
      line_items: [{
        price_data: {
          currency: 'jpy', # 日本円
          unit_amount: 300, # 300円
          recurring: { interval: 'month' }, # 定期購入（毎月）
          product_data: {
            name: '推し鉄.com 月額サブスクリプション' # サービス名
          }
        },
        quantity: 1
      }],
      success_url: "#{request.base_url}/subscriptions/loading",
      cancel_url: "#{request.base_url}/subscriptions/payment_cancel"
    )
    # redirect_to @session.url, allow_other_host: true
  end

  # 決済前のキャンセルのアクション
  def payment_cancel
    flash[:alert] = "Payment was canceled."
    redirect_to index_post_path
  end

  # Stripe Customer 作成
  def create_stripe_customer
    profile = Profile.find_by(user_id: current_user.id)
    user = User.find(current_user.id)
    subscription = Subscription.find_by(user_id: current_user.id)
    begin
      if subscription
        if subscription.stripe_payment_status == "customer_created" || subscription.stripe_payment_status == "canceled"
          redirect_to new_subscription_path
        else
          flash[:alert] = 'Payment was canceled.'
          redirect_to index_post_path
        end
      else
        # Stripe customer create
        customer = Stripe::Customer.create({
          name: "#{profile.last_name} #{profile.first_name}",
          email: user.email
        })
        redirect_to loading_subscription_path
      end
    rescue Stripe::StripeError => e
      # Stripeエラーの処理
      flash[:alert] = e.message
      redirect_to index_post_path
    end
  end

  # ポーリング用のリクエストに応答し、サブスクリプションが完了しているかどうかを返す役割を持つ関数
  def subscription_status
    subscription = Subscription.find_by(user_id: current_user.id)
    if subscription && subscription.stripe_payment_status == 'customer_created'
      render json: { status: 'customer_created' }
    elsif subscription && subscription.stripe_payment_status == 'paid'
      render json: { status: 'paid' }
    else
      render json: { status: 'processing' }
    end
  end

  # カスタマーポータル（クレカ情報の変更）
  def create_customer_portal
    subscription = Subscription.find_by(user_id: current_user.id)
    session = Stripe::BillingPortal::Session.create({
      customer: subscription.stripe_customer_id,
      return_url: "#{request.base_url}/posts/index"
    })
    redirect_to session.url, allow_other_host: true
  end

  def top
    render :top
  end

end
