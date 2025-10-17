class PostsController < ApplicationController
  def index
    @posts = Post.page(params[:page]).per(9)
    @dummy_count = [9 - @posts.size, 0].max
  end

  def show
    @post = Post.find(params[:id])
    @bookmarked = current_user.bookmarked_posts.exists?(@post.id)
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
      flash.now[:error] = "投稿に失敗しました。入力内容を確認してください。"
      redirect_to new_post_path
    end
  end

  def destroy
    post = current_user.posts.find(params[:id])

    urls = case post.image_urls
           when String then JSON.parse(post.image_urls) rescue []
           when Array then post.image_urls
           else []
           end

    urls.reject(&:blank?).each do |url|
      public_id = extract_public_id(url)
      Cloudinary::Uploader.destroy(public_id) if public_id.present?
    end

    post.destroy
    redirect_to posts_path, notice: "投稿と画像を削除しました"
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, image_urls: [], products_attributes: [:title, :description, :url, :image_url])
  end

  def extract_public_id(url)
    uri = URI.parse(url)
    path = uri.path.split('/')
    upload_index = path.index('upload')
    return nil unless upload_index

    public_id_path = path[(upload_index + 1)..]
    public_id_path.join('/').sub(/\.[^\.]+$/, '') rescue nil
  end
end
