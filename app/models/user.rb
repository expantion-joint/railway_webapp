class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :timeoutable, :lockable
  
  has_many :profiles, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :subscription, dependent: :destroy

  VALID_PASSWORD_REGEX = /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[\d])(?=.*?[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?])[A-Za-z\d!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+\z/.freeze
  validates :password, format: { with: VALID_PASSWORD_REGEX, message: 'は半角で大文字・小文字・数字・記号が全て含まれるように入力してください（例:Abc123$）' }, on: :create
  validates :password, format: { with: VALID_PASSWORD_REGEX, message: 'は半角で大文字・小文字・数字・記号が全て含まれるように入力してください（例:Abc123$）' }, allow_blank: true, on: :update

  enum account_type: { regular: 0, admin: 1 }

end
