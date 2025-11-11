class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:create, :destroy]

  def create
    current_user.bookmarked_posts << @post unless current_user.bookmarked_posts.exists?(@post.id)

    respond_to do |format|
      format.html { redirect_to @post, notice: "ブックマークしました" }
      format.json { render json: { status: "bookmarked" }, status: :created }
    end
  end

  def destroy
    current_user.bookmarks.find_by(post: @post)&.destroy

    respond_to do |format|
      format.html { redirect_to bookmarks_path, notice: "ブックマークを解除しました" }
      format.json { render json: { status: "unbookmarked" }, status: :ok }
    end
  end

  def index
    @bookmarked_posts = current_user.bookmarked_posts.page(params[:page]).per(9)
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end