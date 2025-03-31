class CommentsController < ApplicationController
  
  before_action :authenticate_user!
  before_action :check_subscription_status

  def new
    @post = Post.find(params[:post_id])
    @comment = Comment.new
    @comments = Comment.where(post_id: params[:post_id])
    @comment_user_profiles = []
    @comments.each do |comment|
      comment_user_profile = Profile.find_by(user_id: comment.user_id)
      @comment_user_profiles << comment_user_profile
    end
    @profile = Profile.find_by(user_id: @post.user_id)
    @from = params[:id].to_i # 0:postにコメント可能 1:postにコメント不可
    render :new
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      redirect_to new_comment_path(params[:post_id], 0), notice: 'コメントしました'
      begin
        CommentMailer.receive_comment_mail(@comment).deliver_now
      rescue => e
        puts "An error occurred: #{e.message}"
      end
    else
      @post = Post.find(params[:post_id])
      @comments = Comment.where(post_id: params[:post_id])
      @comment_user_profiles = []
      @comments.each do |comment|
        comment_user_profile = Profile.find_by(user_id: comment.user_id)
        @comment_user_profiles << comment_user_profile
      end
      @profile = Profile.find_by(user_id: @post.user_id)
      render :new, status: :unprocessable_entity
    end
  end

  def new_reply
    @post = Post.find(params[:post_id])
    @profile = Profile.find_by(user_id: @post.user_id)
    @comment = Comment.new
    @comments = Comment.where(parent_comment_id: params[:comment_id])
    @comment_user_profiles = []
    @comments.each do |comment|
      comment_user_profile = Profile.find_by(user_id: comment.user_id)
      @comment_user_profiles << comment_user_profile
    end
    
    @parent_comment = Comment.find(params[:comment_id])
    @past_comments = []
    @past_comments << @parent_comment
    past_comment = @parent_comment
    while true
      if past_comment.parent_comment_id.nil?
        break
      else
        past_comment = Comment.find(past_comment.parent_comment_id)
        @past_comments << past_comment
      end
    end
    @past_comments.reverse!
    render :new_reply
  end

  def create_reply
    @comment = Comment.new(comment_params)
    @comment.parent_comment_id = params[:comment_id]
    if @comment.save
      redirect_to new_reply_comment_path(params[:post_id], @comment.id), notice: '返信しました'
      begin
        CommentMailer.receive_comment_mail(@comment).deliver_now
      rescue => e
        puts "An error occurred: #{e.message}"
      end
    else
      parent_comment = Comment.find(params[:comment_id])
      if parent_comment.parent_comment_id
        redirect_to new_reply_comment_path(params[:post_id], parent_comment.parent_comment_id), alert: '返信に失敗しました'
      else
        redirect_to new_comment_path(params[:post_id], 0), alert: '返信に失敗しました'
      end
    end
  end

  def load_relevant_comments
    # 投稿主が current_user の root コメント
    root_comments = Comment.joins(:post)
                          .where(parent_comment_id: nil, posts: { user_id: current_user.id })
    # current_user のコメントに対する返信
    reply_comments = Comment.where(parent_comment_id: Comment.where(user_id: current_user.id).select(:id))
    # 両方を　@comments　にまとめて作成日時の昇順で並び替え、最初の100件を取得
    @comments = (root_comments + reply_comments).sort_by(&:created_at).reverse.first(100)
    # ユーザーIDの一覧からまとめてProfileを取得（1クエリ）
    profiles = Profile.where(user_id: @comments.map(&:user_id).uniq).index_by(&:user_id)
    # コメントごとに対応するプロフィールを並べた配列を作成
    @comment_user_profiles = @comments.map { |comment| profiles[comment.user_id] }
    render :relevant
  end

  def destroy
    @comment = Comment.find(params[:comment_id])
    @comment.destroy
    redirect_to show_profile_path(current_user.id), notice: 'コメントを削除しました'
  end


  private
  def comment_params
    params.require(:comment).permit(:content, :parent_comment_id).merge(post_id: params[:post_id], user_id: current_user.id)
  end
end
