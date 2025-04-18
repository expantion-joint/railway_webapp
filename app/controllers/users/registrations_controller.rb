# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :check_subscription_status, only: [:destroy]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    flash[:notice] = "メールの送信が完了しました。届いたメールを確認し、アカウントを有効化してください。"
    new_session_path(resource_name) # ログイン画面にリダイレクト
  end

  # アカウント削除時にサブスクリプションステータスをチェック
  def check_subscription_status
    subscription = Subscription.find_by(user_id: current_user.id)
    if subscription
      if subscription.stripe_payment_status == 'paid'
        flash[:alert] = 'サブスクリプションをキャンセルしてからアカウントを削除してください。サブスクリプションは、「お支払い情報の変更」でキャンセルできます。'
        redirect_to edit_user_registration_path
      end
    end
  end

end
