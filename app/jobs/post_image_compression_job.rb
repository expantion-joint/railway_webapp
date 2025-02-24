class PostImageCompressionJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post&.media.attached? && post.image?

    # 一時ファイルとしてS3からダウンロード
    temp_image = Tempfile.new(["original_#{post.id}", ".jpg"])
    temp_image.binmode
    temp_image.write(post.media.download)
    temp_image.rewind

    # 圧縮後の一時ファイルを作成
    output_path = Tempfile.new(["compressed_#{post.id}", ".jpg"])
    output_path.binmode

    # MiniMagick を使用して画像を圧縮
    image = MiniMagick::Image.open(temp_image.path)
    image.quality(75) # 画質を75%に設定
    image.resize "1024x1024>" # 最大1024pxにリサイズ（元サイズ以下なら変更なし）
    image.write(output_path.path)

    # **元の画像を削除**
    post.media.purge

    # **圧縮画像を再アップロード**
    post.media.attach(io: File.open(output_path.path), filename: "compressed_#{post.id}.jpg", content_type: "image/jpeg")

    # **一時ファイルを削除**
    temp_image.close
    temp_image.unlink
    output_path.close
    output_path.unlink

    Rails.logger.info "Post #{post.id} image compressed and replaced successfully!"
  end
end

