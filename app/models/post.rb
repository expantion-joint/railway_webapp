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

  before_destroy :purge_media
  
  # 選択肢
  enum category: { 撮り鉄: 1, 乗り鉄: 2, 音鉄:3, 車両鉄:4, 模型鉄:5, 時刻表鉄:6, 葬式鉄:7, 廃線鉄:8, 歴史鉄:9, 駅鉄:10, 駅弁鉄:11, 線路鉄:12, 設備鉄:13, 運転鉄:14, 保安鉄:15, ママ鉄:16, 架空鉄:17, 配線鉄:18, ゲーム鉄:19, その他:99}

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

  # postを削除する際、S3に保存されたmediaも削除する
  def purge_media
    media.purge if media.attached?
  end

  # 動画のサムネイルを作成（ffmpeg必要）
  def video_thumbnail
    return unless media.content_type.start_with?("video/")
    media.representation(resize_to_limit: [1280, 720]).processed
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
