class PostsController < ApplicationController
  def index
    @posts = Post.all
    @dummy_count = [9 - @posts.size, 0].max
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
    10.times { @post.products.build }
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: "投稿が完了しました"
    else
      render :new
    end
  end


  private

  def post_params
    params.require(:post).permit(:title, :body, image_urls: [], products_attributes: [:title, :description, :url, :image_url])
  end
end
