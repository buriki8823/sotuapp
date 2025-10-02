class PostsController < ApplicationController
  def index
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
  @post = Post.new
end

def create
  @post = current_user.posts.build(post_params)
  if @post.save
    redirect_to post_path(@post), notice: "投稿が完了しました"
  else
    render :new
  end
end

private

def post_params
  params.require(:post).permit(:title, :body, :image)
end

end
