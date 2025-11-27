class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:create, :destroy]

  def create
    # UUID 化に対応 → exists?(@post.uuid) に変更
    current_user.bookmarked_posts << @post unless current_user.bookmarked_posts.exists?(@post.uuid)

    respond_to do |format|
      format.html { redirect_to @post, notice: "ブックマークしました" }
      format.json { render json: { status: "bookmarked" }, status: :created }
    end
  end

  def destroy
    # post: @post のままでOK（外部キーは id のまま残す方針）
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
    # UUID 化に対応
    @post = Post.find_by(uuid: params[:post_id])
  end
end