class ProfilesController < ApplicationController

  before_action :authenticate_user!
  before_action :check_subscription_status, only: [:show]
  
  def new
    @profile = Profile.new
    render :new
  end
  
  def create
    @profile = Profile.new(profile_params)
    if params[:profile][:image]
      @profile.image.attach(params[:profile][:image])
    end
    if @profile.save
      redirect_to top_subscription_path, notice: '登録しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @profile = Profile.find_by(user_id: current_user.id)
    render :edit
  end

  def update
    @profile = Profile.find_by(user_id: current_user.id)
    if params[:profile][:image]
      @profile.image.attach(params[:profile][:image])
    end
    if @profile.update(profile_params)
      redirect_to show_profile_path(current_user.id), notice: '更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @comment = Comment.new
    @profile = Profile.find_by(user_id: params[:user_id])
    @likes = Like.where(user_id: params[:user_id])
  
    if params[:type] == "post"
      @type = "post"
      @posts = Post.where(user_id: params[:user_id]).order(created_at: :desc).page(params[:page]).per(100)
      @comment_count = @posts.map { |post| Comment.where(post_id: post.id).count }
    elsif params[:type] == "comment"
      @type = "comment"
      @comments = Comment.where(user_id: params[:user_id]).order(created_at: :desc).page(params[:page]).per(100)
  
      # 各コメントに対応するユーザーのプロフィールを取得
      @comment_user_profiles = @comments.map { |comment| Profile.find_by(user_id: comment.user_id) }
    elsif params[:type] == "like_post"
      @type = "like_post"
      @like_posts = Post.where(id: Like.where(user_id: params[:user_id]).pluck(:post_id))
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(100)
      @like_posts_comment_count = @like_posts.map { |post| Comment.where(post_id: post.id).count }
      
      # 各投稿に対応するユーザーのプロフィールを取得
      @like_post_user_profiles = @like_posts.map { |like_post| Profile.find_by(user_id: like_post.user_id) }
    else
      @type = "post"
      @posts = Post.where(user_id: params[:user_id]).order(created_at: :desc).page(params[:page]).per(100)
      @comments = Comment.where(user_id: params[:user_id]).order(created_at: :desc).page(params[:page]).per(100)
      @comment_count = @posts.map { |post| Comment.where(post_id: post.id).count }
      @comment_user_profiles = @comments.map { |comment| Profile.find_by(user_id: comment.user_id) }
      @like_posts = Post.where(id: Like.where(user_id: params[:user_id]).pluck(:post_id))
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(100)
      @like_posts_comment_count = @like_posts.map { |post| Comment.where(post_id: post.id).count }
      @like_post_user_profiles = @like_posts.map { |like_post| Profile.find_by(user_id: like_post.user_id) }
    end
  
    respond_to do |format|
      format.html # 初回ロード
      format.js   # "もっと読み込む" ボタンのクリック時
    end
  end
  

  private
  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :nickname, :gender, :birthday, :self_introduction, :self_introduction_url, :image, :prefecture).merge(user_id: current_user.id)
  end

end
