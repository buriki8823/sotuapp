class SearchesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:autocomplete]

  def search
    query = params[:q]
    @posts = Post.joins(:user)
                 .where("posts.title LIKE :q OR users.name LIKE :q", q: "%#{query}%")
                 .page(params[:page]).per(12)

    @dummy_count = 12 - @posts.size
  end

  def autocomplete
    query = params[:q]
    return render json: [] if query.blank?

    title_matches = Post.where("title LIKE ?", "%#{query}%").limit(5).pluck(:title)
    user_matches = User.where("name LIKE ?", "%#{query}%").limit(5).pluck(:name)

    suggestions = (title_matches + user_matches).uniq
    render json: suggestions
  end
end
