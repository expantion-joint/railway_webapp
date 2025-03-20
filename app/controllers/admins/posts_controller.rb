class Admins::PostsController < ApplicationController
	before_action :authenticate_admin!
	
	def index
    @posts = Post.all
  end

	def destroy
    @post = Post.find(params[:post_id])
    @post.destroy
    redirect_to index_admin_post_path, notice: '投稿を削除しました。'
  end

  def media_index
    @posts = Post.with_attached_media
  end

  def compress_media
    @post = Post.find(params[:post_id])
    if @post.media.attached? &&  @post.media.content_type.start_with?('video/')
      VideoCompressionJob.perform_later(@post.id) # 圧縮処理を非同期で実行
      redirect_to media_index_admin_post_path, notice: '動画の圧縮処理を実行しました'
    elsif @post.media.attached? &&  @post.media.content_type.start_with?('image/')
      PostImageCompressionJob.perform_later(@post.id) # 圧縮処理を非同期で実行
      redirect_to media_index_admin_post_path, notice: '画像の圧縮処理を実行しました'
    else
      redirect_to media_index_admin_post_path, alert: 'メディアがありません'
    end
  end

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to index_post_path, alert: '管理者のみがアクセスできます。'
    end
  end

end
