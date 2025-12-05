class CommentsController < ApplicationController
  def create
    # UUIDで投稿を取得
    @post = Post.find_by(uuid: params[:post_id])

    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      render json: {
        body: @comment.body,
        user_name: @comment.user.name,
        created_at: @comment.created_at.strftime("%Y-%m-%d %H:%M")
      }, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
