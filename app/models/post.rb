class Post < ApplicationRecord
  belongs_to :user
  belongs_to :profile

  validates :category, presence: true
  validates :title, presence: true
  validates :body, presence: true
  # validates :tag, presence: true
  validates :media, size: { less_than: 20.megabytes }

  has_one_attached :media, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  after_save :convert_video_async, if: -> { media.attached? && video? && valid_media?}
  after_save :convert_image_async, if: -> { media.attached? && image? && valid_media?}
  
  # 選択肢
  enum category: { 撮り鉄: 1, 乗り鉄: 2, 模型鉄: 3 }

  # ファイルが動画かどうか判定
  def video?
    return false unless media.attached?
    media.content_type.start_with?("video/")
  end

  # ファイルが画像かどうか判定
  def image?
    return false unless media.attached?
    media.content_type.start_with?("image/")
  end

  # ファイル名にcompressedが含まれているか判定
  def valid_media?
    return false unless media.attached?
    filename = media.filename.to_s
    !filename.include?('compressed')
  end

  # # 未圧縮の画像・動画を取得するメソッド
  # def self.uncompressed_videos
  #   joins(media_attachment: :blob)
  #     .where.not("active_storage_blobs.filename LIKE ?", "%compressed%")
  # end

  private

  # 非同期で動画を変換 & 圧縮
  def convert_video_async
    VideoCompressionJob.perform_later(id)
  end

  # 非同期で画像を変換 & 圧縮
  def convert_image_async
    PostImageCompressionJob.perform_later(id)
  end

end
