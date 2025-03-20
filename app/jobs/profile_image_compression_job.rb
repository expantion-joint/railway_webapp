class ProfileImageCompressionJob < ApplicationJob
  queue_as :default

  def perform(profile_id)
    profile = Profile.find_by(id: profile_id)
    return unless profile&.image.attached? && profile.image?

    # 一時ファイルとしてS3からダウンロード
    temp_image = Tempfile.new(["original_#{profile.id}", ".jpg"])
    temp_image.binmode
    temp_image.write(profile.image.download)
    temp_image.rewind

    # 圧縮後の一時ファイルを作成
    output_path = Tempfile.new(["compressed_#{profile.id}", ".jpg"])
    output_path.binmode

    # MiniMagick を使用して画像を圧縮
    image = MiniMagick::Image.open(temp_image.path)
    image.quality(75) # 画質を75%に設定
    image.resize "1024x1024>" # 最大1024pxにリサイズ（元サイズ以下なら変更なし）
    image.write(output_path.path)

    # **元の画像を削除**
    profile.image.purge

    # **圧縮画像を image に置き換え**
    profile.image.attach(io: File.open(output_path.path), filename: "compressed_#{profile.id}.jpg", content_type: "image/jpeg")

    # **一時ファイルを削除**
    temp_image.close
    temp_image.unlink
    output_path.close
    output_path.unlink

    Rails.logger.info "Profile #{profile.id} image compressed and replaced successfully!"
  end
end

