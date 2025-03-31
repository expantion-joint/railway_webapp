class DailyReportMailer < ApplicationMailer

  def send_report(csv_data)
    attachments["daily_report_#{Date.today}.csv"] = {
      mime_type: 'text/csv',
      content: csv_data
    }
    mail(
      to: ENV["GMAIL_USERNAME"],
      # bcc: ENV["ACTION_MAILER_USER"],
      from: ENV["MAIL_FROM"],
      subject: "【日次レポート】ユーザー・投稿数集計"
      )
  end

end
