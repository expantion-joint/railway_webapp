class StripeMailer < ApplicationMailer

  def payment_failed_mail(user, session)
    @user = user
    @profile = Profile.find_by(user_id: @user.id)
    @session = session
    # @url = "http://localhost:8080"
    @url = "https://oshitetsu.com"
    mail(
    to: @user.email,
    # bcc: ENV["ACTION_MAILER_USER"],
    from: ENV["MAIL_FROM"],
    subject: 'サブスクリプションのお支払いに失敗しました'
    )
  end

end
