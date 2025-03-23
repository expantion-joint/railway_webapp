class PostsController < ApplicationController

  before_action :authenticate_user!
  before_action :check_subscription_status

  def index
    title = params[:title]
    category = params[:category]
    if title.present?
      @posts = Post.where('title LIKE ?', "%#{title}%")
    elsif category.present?
      @posts = Post.where('category LIKE ?', "%#{category}%")
      @category = Post.new
      @category.category = params[:category].to_i
    else
      @posts = Post.all
    end
    @posts = @posts.order(created_at: :desc)
    # ページネーションを追加 (100件ずつ表示)
    @posts = @posts.page(params[:page]).per(10) #100に変更
    @profiles = @posts.map(&:profile)
    # 投稿毎のコメント数の算出
    @comment_count = []
    @posts.each do |post|
      @comments = Comment.where(post_id: post.id)
      @comment_count << @comments.count
    end
    #非同期リクエストに対応
    respond_to do |format|
      format.html # 初回ロード
      format.js   # "もっと読み込む" ボタンのクリック時
    end
    # render :index
  end
  
  def new
    @post = Post.new
    render :new
  end
  
  def create
    @post = Post.new(post_params)
    @profile = Profile.find_by(user_id: current_user.id)
    @post.profile_id = @profile.id
    if params[:post][:media]
      @post.media.attach(params[:post][:media])
    end
    if @post.save
      redirect_to index_post_path, notice: '投稿しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @post = Post.find(params[:post_id])
    render :edit
  end

  def update
    @post = Post.find(params[:post_id])
    # 古いメディアがあれば削除（後で purge する用に保持）
    old_media = @post.media if params[:post][:media].present? && @post.media.attached?
    # 新しいメディアをアタッチ
    @post.media.attach(params[:post][:media]) if params[:post][:media]
    if @post.update(post_params)
      old_media&.purge_later
      redirect_to index_post_path, notice: '更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post.destroy
    redirect_to index_post_path, notice: '削除しました'
  end

  private
  def post_params
    params.require(:post).permit(:category, :title, :body, :tag, :media).merge(user_id: current_user.id)
  end

end
