class ApplicationController < ActionController::Base

  before_action :authenticate_user!
  before_action :find_subscription
  before_action :update_last_seen_at, if: :user_signed_in?

  protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      index_admin_dashboard_path
    elsif resource.is_a?(User)
      profile = Profile.find_by(user_id: resource.id)
      if profile.nil?
        new_profile_path
      else
        # 現在のユーザーのsubscriptionを取得
        subscription = Subscription.find_by(user_id: resource.id)
        # subscriptionが存在し、stripe_payment_statusに基づいてリダイレクト先を分岐
        if subscription.nil? || subscription.stripe_payment_status == "customer_created" || subscription.stripe_payment_status == "canceled" || subscription.stripe_payment_status.nil?
          top_subscription_path
        else
          index_post_path
        end
      end
    end
  end

  def check_subscription_status
    # 現在のユーザーのsubscriptionを取得
    subscription = Subscription.find_by(user_id: current_user.id)
    # subscriptionがnilの場合、またはstatusが特定の状態の場合、アクセスを拒否
    if subscription.nil? || subscription.stripe_payment_status == "customer_created" || subscription.stripe_payment_status == "canceled" || subscription.stripe_payment_status.nil?
      redirect_to index_home_path, alert: "サブスク登録してください"
    end
  end

  def find_subscription
    if current_user
      @subscription = Subscription.find_by(user_id: current_user.id)
      if @subscription.nil?
        @subscription = Subscription.new
        @subscription.stripe_payment_status = "not_created_subscription"
      end
    end
  end

  # ユーザーがアクセスした日時を記録
  def update_last_seen_at
    current_user.update_column(:last_seen_at, Time.current)
  end

end
