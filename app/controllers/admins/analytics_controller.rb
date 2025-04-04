class Admins::AnalyticsController < ApplicationController
  before_action :authenticate_admin!

  def index
    # 今日、昨日、過去7日間にアクセスしたユーザー数
    @today_active_users = User.where("last_seen_at >= ?", Time.zone.now.beginning_of_day).count
    @yesterday_active_users = User.where(last_seen_at: 1.day.ago.beginning_of_day..1.day.ago.end_of_day).count
    @weekly_active_users = User.where("last_seen_at >= ?", 7.days.ago).count

    # 今日、昨日、過去7日間の投稿数
    @today_post_count = Post.where(created_at: Time.zone.today.all_day).count
    @yesterday_post_count = Post.where(created_at: 1.day.ago.to_date.all_day).count
    @weekly_post_count = Post.where(created_at: 7.days.ago.beginning_of_day..Time.zone.now.end_of_day).count

    # ユーザー数を県ごとに集計
    @prefecture_counts = Profile.group(:prefecture).order('count_all DESC').count

    # ユーザー数を年代ごとに集計
    @age_groups = Profile.all.group_by(&:age_group).transform_values(&:count)
  end

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to index_post_path, alert: '管理者のみがアクセスできます。'
    end
  end

end
