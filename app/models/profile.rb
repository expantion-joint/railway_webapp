class Profile < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :nickname, presence: true
  validates :gender, presence: true
  validates :birthday, presence: true

  has_one_attached :image, dependent: :destroy
  has_many :posts, dependent: :destroy

  after_save :convert_image_async, if: -> { image.attached? && valid_image?}
  before_destroy :purge_image

  # 選択肢
  enum gender: { 男性: "Male", 女性: "Female", その他: "Others" }

  def valid_image?
    return false unless image.attached?
    filename = image.filename.to_s
    !filename.include?('compressed')
  end

  def image?
    return false unless image.attached?
    image.content_type.start_with?("image/")
  end

  def purge_image
    image.purge if image.attached?
  end

  # 生年月日から年齢を算出
  def age
		return nil unless birthday
		now = Time.zone.now
		age = now.year - birthday.year
		age -= 1 if birthday.to_date.change(year: now.year) > now.to_date
		age
	end

	def age_group
		return "不明" unless age
		case age
		when 0..9
			"10歳未満"
		when 10..19
			"10代"
		when 20..29
			"20代"
		when 30..39
			"30代"
		when 40..49
			"40代"
		when 50..59
			"50代"
		when 60..69
			"60代"
		else
			"70代以上"
		end
	end

  private

  # 非同期で画像を変換 & 圧縮
  def convert_image_async
    ProfileImageCompressionJob.perform_later(id)
  end

end
