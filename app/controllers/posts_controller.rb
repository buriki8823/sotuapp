class PostsController < ApplicationController
  def index
    sorted_posts = case params[:sort]
                   when "cute"
                     Post.order_by_kind("cute")
                   when "cool"
                     Post.order_by_kind("cool")
                   when "stylish"
                     Post.order_by_kind("stylish")
                   when "healing"
                     Post.order_by_kind("healing")
                   when "aesthetic"
                     Post.order_by_kind("aesthetic")
                   when "popular"
                     Post.order_by_total_evaluations
                   else
                     Post.all.order(created_at: :desc)
                   end

    @posts = sorted_posts.page(params[:page]).per(9)
    @dummy_count = [9 - @posts.length, 0].max
  end

  def show
    @post = Post.find_by(uuid: params[:id])
    @bookmarked = current_user.bookmarked_posts.exists?(@post.uuid)
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
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    post = current_user.posts.find_by(uuid: params[:id])

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

  def my_posts
    @posts = current_user.posts.page(params[:page]).per(9)
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :rating_enabled, image_urls: [], products_attributes: [:title, :description, :url, :image_url])
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