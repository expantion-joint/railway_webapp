# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# 初期アカウントの作成
User.create!(
	email: ENV['USER_EMAIL_1'],
	password: ENV['USER_PASSWORD'],
	password_confirmation: ENV['USER_PASSWORD'],
	account_type: User.account_types[:admin]
)

Admin.create!(
	email: ENV['ADMIN_EMAIL_1'],
	password: ENV['ADMIN_PASSWORD'],
	password_confirmation: ENV['ADMIN_PASSWORD'],
)

Profile.create!(
	user_id: ENV['ADMIN_PROFILE_USER_ID_1'],
	first_name: 'admin',
	last_name: 'admin',
	nickname: 'admin',
	gender: 'Male',
	birthday: '2025-01-01'
)

Subscription.create!(
	user_id: ENV['ADMIN_PROFILE_USER_ID_1'],
	stripe_customer_id: 'admin',
	stripe_payment_status: 'paid',
	stripe_customer_event_id: 'admin'
)

User.create!(
	email: ENV['USER_EMAIL_2'],
	password: ENV['USER_PASSWORD'],
	password_confirmation: ENV['USER_PASSWORD'],
	account_type: User.account_types[:admin]
)

Admin.create!(
	email: ENV['ADMIN_EMAIL_2'],
	password: ENV['ADMIN_PASSWORD'],
	password_confirmation: ENV['ADMIN_PASSWORD'],
)

Profile.create!(
	user_id: ENV['ADMIN_PROFILE_USER_ID_2'],
	first_name: 'admin2',
	last_name: 'admin2',
	nickname: 'admin2',
	gender: 'Male',
	birthday: '2025-01-01'
)

Subscription.create!(
	user_id: ENV['ADMIN_PROFILE_USER_ID_2'],
	stripe_customer_id: 'admin2',
	stripe_payment_status: 'paid',
	stripe_customer_event_id: 'admin2'
)