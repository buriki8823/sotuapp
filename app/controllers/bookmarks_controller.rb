class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    post = Post.find(params[:post_id])
    current_user.bookmarked_posts << post unless current_user.bookmarked_posts.exists?(post.id)
    head :ok
  end

  def destroy
    post = Post.find(params[:post_id])
    current_user.bookmarks.find_by(post: post)&.destroy

    respond_to do |format|
      format.html { redirect_to bookmarks_path, notice: "ブックマークを解除しました" }
      format.json { head :no_content }
    end
  end

  def index
    @bookmarked_posts = current_user.bookmarked_posts.page(params[:page]).per(9)
  end
end