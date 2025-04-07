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
      .where(created_at: start_of_last_week..end_of_last_week)        # 先週のデータを取得
      .joins("INNER JOIN posts ON posts.id = #{table_name}.post_id")  # 「いいね」と「その対象となった投稿」をセットで扱う
      .group("posts.user_id")                                         # 投稿者ごとにグループ化
      .order("COUNT(posts.user_id) DESC")                             # いいねの数が多い順に並べる
      .limit(10)                                                      # 上位10のみ
      .count                                                          # 投稿者ごとの「いいね数」をカウント

    # 結果を整形
    recent_likes_count_weekly.map do |post_user_id, count|
      profile = profiles.find_by(user_id: post_user_id)
      [profile&.nickname || 'Unknown User', count, post_user_id]
    end
    return recent_likes_count_weekly
  end

end
