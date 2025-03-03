class ContactMailer < ApplicationMailer
  
  def receive_contact_mail(email, subject, message)
    @email = email
    @subject = subject
    @message = message
    
    mail(
    to: ENV["GMAIL_USERNAME"],
    # bcc: ENV["ACTION_MAILER_USER"],
    from: ENV["MAIL_FROM"],
    subject: 'お問い合わせ'
    )
  end

end
