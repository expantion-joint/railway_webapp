class Admins::SubscriptionsController < ApplicationController
	before_action :authenticate_admin!
	
	def index
    @subscriptions = Subscription.all
  end

  def edit
    @subscription = Subscription.find(params[:subscription_id])
  end

  def update
    @subscription = Subscription.find(params[:subscription_id])
    if @subscription.update(subscription_params)
      redirect_to index_admin_subscription_path, notice: 'ユーザー情報を更新しました。'
    else
      render :edit, alert: '更新に失敗しました。'
    end
  end

	def destroy
    @subscription = Subscription.find(params[:subscription_id])
    if @subscription.user_id == current_user.id
      redirect_to index_admin_subscription_path, alert: '自分自身を削除することはできません。'
    else
      @subscription.destroy
      redirect_to index_admin_subscription_path, notice: 'ユーザーを削除しました。'
    end
  end

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to index_post_path, alert: '管理者のみがアクセスできます。'
    end
  end

  def subscription_params
    params.require(:subscription).permit(:stripe_payment_status, :stripe_subscription_id, :stripe_customer_id)
  end

end
