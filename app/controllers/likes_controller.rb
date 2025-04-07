class LikesController < ApplicationController

  before_action :authenticate_user!
  before_action :check_subscription_status

  def create
    @post = Post.find(params[:post_id])
    @post.likes.create(user: current_user)
    render json: { liked: true, like_count: @post.likes.count }
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post.likes.find_by(user: current_user).destroy
    render json: { liked: false, like_count: @post.likes.count }
  end

  def show
    # 先週の開始日と終了日を計算
    @start_of_last_week = 1.week.ago.beginning_of_week
    @end_of_last_week = 1.week.ago.end_of_week
    # 1週間以内のいいねを user_id ごとに集計
    @recent_likes_count_weekly = Like.recent_likes_count_weekly(Profile.all, @start_of_last_week, @end_of_last_week)
    render :show
  end

  private
  def like_params
    params.require(:like).merge(user_id: current_user.id, post_id: post_id)
  end

end
