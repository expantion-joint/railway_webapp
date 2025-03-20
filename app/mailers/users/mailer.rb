class Users::Mailer < Devise::Mailer
  default template_path: 'users/mailer' # カスタムテンプレートパスを指定
end