class VideoCompressionJob < ApplicationJob
  queue_as :default
  
  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post&.media.attached? && post.video?

    # 一時ファイルにS3からダウンロード
    temp_video = Tempfile.open(['video', '.mp4'], binmode: true)
    temp_video.write(post.media.download)
    temp_video.rewind

    # 圧縮後の一時ファイルを作成（Tempfileを使用）
    output_tempfile = Tempfile.new(['compressed_video', '.mp4'], binmode: true)

    movie = FFMPEG::Movie.new(temp_video.path)

    # FFmpeg で動画を圧縮（1280x720以上ならリサイズ、それ以下なら変更なし）
    if movie.width > 1280 || movie.height > 720
      options = {
        video_codec: 'libx264',
        audio_codec: 'aac',
        video_bitrate: '500k',
        audio_bitrate: '96k',
        resolution: '1280x720'  # 1280x720以上の場合のみ適用
      }
    else
      options = {
        video_codec: 'libx264',
        audio_codec: 'aac',
        video_bitrate: '500k',
        audio_bitrate: '96k'
      }
    end
    movie.transcode(output_tempfile.path, options)

    # **元の動画を削除**
    post.media.purge

    # **圧縮動画を S3 に再アップロード**
    post.media.attach(io: File.open(output_tempfile.path), filename: "compressed_#{post.id}.mp4", content_type: "video/mp4")

    # **一時ファイルを削除**
    temp_video.close
    temp_video.unlink
    output_tempfile.close
    output_tempfile.unlink

    Rails.logger.info "Post #{post.id} video compressed and replaced successfully!"
  end
end

