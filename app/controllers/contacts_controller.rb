class ContactsController < ApplicationController

  before_action :authenticate_user!

	def new
		render :new
	end

	def create
		email = params[:email]
		subject = params[:subject]
		message = params[:message]

		if email.present? && subject.present? && message.present?
			ContactMailer.receive_contact_mail(email, subject, message).deliver_now
			flash[:notice] = "お問い合わせが送信されました。"
			redirect_to new_contact_path
		else
			flash[:alert] = "すべての項目を入力してください。"
			render :new
		end
	end

end
