class Admins::ProfilesController < ApplicationController
	before_action :authenticate_admin!
	
	def index
    @profiles = Profile.all
  end

	def destroy
    @profile = Profile.find(params[:profile_id])
    @profile.destroy
    redirect_to index_admin_profile_path, notice: 'プロフィールを削除しました。'
  end

  def media_index
    @profiles = Profile.with_attached_image
  end

  def compress_media
    @profile = Profile.find(params[:profile_id])
    if @profile.image.attached? &&  @profile.image.content_type.start_with?('image/')
      ProfileImageCompressionJob.perform_later(@profile.id) # 圧縮処理を非同期で実行
      redirect_to media_index_admin_profile_path, notice: '動画の圧縮処理を実行しました'
    else
      redirect_to media_index_admin_profile_path, alert: 'メディアがありません'
    end
  end

  private

  def authenticate_admin!
    unless current_user&.admin?
      redirect_to index_post_path, alert: '管理者のみがアクセスできます。'
    end
  end

end
