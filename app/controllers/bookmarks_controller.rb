class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [ :create, :destroy ]

  def create
    # UUID 化に対応
    unless current_user.bookmarked_posts.exists?(uuid: @post.uuid)
      current_user.bookmarked_posts << @post
    end

    render json: { status: "bookmarked" }, status: :created
  end

  def destroy
    current_user.bookmarks.find_by(post: @post)&.destroy
    render json: { status: "unbookmarked" }, status: :ok
  end

  def index
    @bookmarked_posts = current_user.bookmarked_posts.page(params[:page]).per(9)
    # 一覧はHTMLで使うのでそのままビューを返す
  end

  private

  def set_post
    @post = Post.find_by(uuid: params[:post_id] || params[:id])
  end
end
