class Admins::CommentsController < ApplicationController
	before_action :authenticate_admin!
	
	def index
    @comments = Comment.all
  end

	def destroy
    @comment = Comment.find(params[:comment_id])
    @comment.destroy
    redirect_to index_admin_comment_path, notice: '投稿を削除しました。'
  end

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to index_post_path, alert: '管理者のみがアクセスできます。'
    end
  end
end
