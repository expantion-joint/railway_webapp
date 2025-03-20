class CompressUncompressedVideosJob < ApplicationJob
  queue_as :default

  def perform
    Post.uncompressed_videos.find_each do |post|
      next unless post.video?
      VideoCompressionJob.perform_later(post.id)
    end
  end
end
