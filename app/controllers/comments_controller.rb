class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to post_path(@post), notice: "コメントを投稿しました"
    else
      redirect_to post_path(@post), alert: "コメントの投稿に失敗しました"
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
