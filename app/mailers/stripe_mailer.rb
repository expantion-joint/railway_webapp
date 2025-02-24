class StripeMailer < ApplicationMailer

  def payment_failed_mail(user, session)
    @user = user
    @profile = Profile.find_by(user_id: @user.id)
    @session = session
    @url = "http://localhost:8080"
    mail(
    to: @user.email,
    # bcc: ENV["ACTION_MAILER_USER"],
    from: '推し鉄.com',
    subject: 'サブスクリプションのお支払いに失敗しました'
    )
  end

end
