class ActiveStorageCleanMailer < ApplicationMailer

  def deleted_files_report(file_names)
    @file_names = file_names
    mail(
      to: ENV["GMAIL_USERNAME"],
      # bcc: ENV["ACTION_MAILER_USER"],
      from: ENV["MAIL_FROM"],
      subject: "【通知】未使用の添付ファイルを削除しました (#{@file_names.size}件)"
      )
  end

end
  