class Admins::DashboardsController < ApplicationController
	before_action :authenticate_admin!
	
	def index
    render :index
  end

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to index_post_path, alert: '管理者のみがアクセスできます。'
    end
  end
end
