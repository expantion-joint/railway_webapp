class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # いいね済みか確認する関数
  def self.exists_for_user_and_post(user_id, post_id)
    where(user_id: user_id, post_id: post_id).exists?
  end

  # 1週間以内のいいねを user_id ごとに集計する関数
  def self.recent_likes_count_weekly(profiles, start_of_last_week, end_of_last_week)
    recent_likes_count_weekly = self
      .where(created_at: start_of_last_week..end_of_last_week)  # 先週のデータを取得
      .group(:user_id)                                          # user_id 毎にグループ化
      .order('COUNT(user_id) DESC')                             # いいねの数が多い順に並べる
      .limit(10)                                                # 上位10のみ
      .count                                                    # 各 user_id 毎のいいね数を集計
    
    recent_likes_count_weekly = recent_likes_count_weekly.map do |user_id, count|
      profile = profiles.find_by(user_id: user_id)  # ユーザーを検索
      [profile&.nickname || 'Unknown User', count, user_id]  # ニックネームといいね数とuser_idのペア
    end
    return recent_likes_count_weekly
  end

end
