class SearchesController < ApplicationController
  def search
    query = params[:q]
    @posts = Post.joins(:user)
                 .where("posts.title LIKE :q OR users.name LIKE :q", q: "%#{query}%")
                 .page(params[:page]).per(12)

    @dummy_count = 12 - @posts.size
  end
end
