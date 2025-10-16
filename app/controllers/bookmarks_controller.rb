class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    post = Post.find(params[:post_id])
    current_user.bookmarked_posts << post unless current_user.bookmarked_posts.exists?(post.id)
    redirect_to post_path(post), notice: "ブックマークしました"
  end

  def destroy
    post = Post.find(params[:post_id])
    current_user.bookmarked_posts.destroy(post)
    redirect_to post_path(post), notice: "ブックマークを解除しました"
  end

  def index
    @bookmarked_posts = current_user.bookmarked_posts.page(params[:page]).per(9)
  end
end