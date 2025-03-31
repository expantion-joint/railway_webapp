require "csv"

class DailyReportService
  def self.generate_csv
    utf8_csv = CSV.generate(headers: true) do |csv|
      csv << ["項目", "件数"]
      csv << ["今日のアクティブユーザー", User.where("last_seen_at >= ?", Time.zone.now.beginning_of_day).count]
      csv << ["昨日のアクティブユーザー", User.where(last_seen_at: 1.day.ago.beginning_of_day..1.day.ago.end_of_day).count]
      csv << ["過去7日のアクティブユーザー", User.where("last_seen_at >= ?", 7.days.ago).count]

      csv << ["今日の投稿数", Post.where(created_at: Time.zone.today.all_day).count]
      csv << ["昨日の投稿数", Post.where(created_at: 1.day.ago.to_date.all_day).count]
      csv << ["過去7日の投稿数", Post.where(created_at: 7.days.ago.beginning_of_day..Time.zone.now.end_of_day).count]

      csv << []
      csv << ["--- 都道府県別ユーザー数 ---"]
      Profile.group(:prefecture).order('count_all DESC').count.each do |pref, count|
        csv << [pref.presence || "未登録", count]
      end

      csv << []
      csv << ["--- 年代別ユーザー数 ---"]
      Profile.all.group_by(&:age_group).transform_values(&:count).each do |group, count|
        csv << [group, count]
      end
    end
    utf8_csv.encode(Encoding::SJIS, invalid: :replace, undef: :replace)
  end
end
