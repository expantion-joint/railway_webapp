class CommentMailer < ApplicationMailer
  
  def receive_comment_mail(comment)
    if comment.parent_comment_id
      parent = Comment.find(comment.parent_comment_id)
      @url = Rails.application.routes.url_helpers.new_reply_comment_url(
        post_id: comment.post_id,
        comment_id: comment.parent_comment_id,
        host: "oshitetsu.com"
        # host: "localhost:8080"
      )
    else
      parent = Post.find(comment.post_id)
      @url = Rails.application.routes.url_helpers.new_comment_url(
        post_id: comment.post_id,
        id: 1, # 0:postにコメント可能 1:postにコメント不可
        host: "oshitetsu.com"
        # host: "localhost:8080"
      )
    end
    @comment = comment
    @parent_user = User.find(parent.user_id)
    @parent_profile = Profile.find_by(user_id: @parent_user.id)
    @user = User.find(comment.user_id)
    @profile = Profile.find_by(user_id: @user.id)
    
    mail(
    to: @parent_user.email,
    # bcc: ENV["ACTION_MAILER_USER"],
    from: ENV["MAIL_FROM"],
    subject: 'コメントが届きました'
    )
  end

end
