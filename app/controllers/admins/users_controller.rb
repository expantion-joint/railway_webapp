class Admins::UsersController < ApplicationController
	before_action :authenticate_admin!
	
	def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:user_id])
  end

  def update
    @user = User.find(params[:user_id])
    if @user.update(user_params)
      redirect_to index_admin_user_path, notice: 'ユーザー情報を更新しました。'
    else
      render :edit, alert: '更新に失敗しました。'
    end
  end

	def destroy
    @user = User.find(params[:user_id])
    if @user == current_user
      redirect_to index_admin_user_path, alert: '自分自身を削除することはできません。'
    else
      @user.destroy
      redirect_to index_admin_user_path, notice: 'ユーザーを削除しました。'
    end
  end

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to index_post_path, alert: '管理者のみがアクセスできます。'
    end
  end

  def user_params
    params.require(:user).permit(:email, :account_type, :failed_attempts)
  end

end
