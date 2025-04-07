class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # いいね済みか確認する関数
  def self.exists_for_user_and_post(user_id, post_id)
    where(user_id: user_id, post_id: post_id).exists?
  end

  # 1週間以内のいいねを user_id ごとに集計する関数
  def self.recent_likes_count_weekly(profiles, start_of_last_week, end_of_last_week)
    likes_weekly = self.where(created_at: start_of_last_week..end_of_last_week)
    posts = Post.where(id: likes_weekly.pluck(:post_id))
    user_ids = posts.pluck(:user_id)
    top_users = user_ids.tally.sort_by { |_, count| -count }.first(10)

    recent_likes_count_weekly = top_users.map do |user_id, count|
      profile = Profile.find_by(user_id: user_id)
      nickname = profile&.nickname || "Unknown User"
      [nickname, count, user_id]
    end
    return recent_likes_count_weekly
  end

end
