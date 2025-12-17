class SearchesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :autocomplete ]

  def search
    query = params[:q].to_s.strip
    normalized = normalize_query(query)

    @posts = Post.joins(:user)
                 .where(
                   "posts.title LIKE :q OR posts.title LIKE :n OR users.name LIKE :q OR users.name LIKE :n",
                   q: "%#{query}%",
                   n: "%#{normalized}%"
                 )
                 .page(params[:page]).per(12)

    @dummy_count = 12 - @posts.size
  end

  def autocomplete
    q = params[:q].to_s.strip
    return render json: [] if q.blank?

    normalized = normalize_query(q)

    users = User.where("name_hira LIKE ?", "%#{normalized}%")
                .limit(5)
                .pluck(:name)

    posts = Post.where("title LIKE ? OR title LIKE ?", "%#{q}%", "%#{normalized}%")
                .limit(5)
                .pluck(:title)

    render json: (users + posts).uniq
  end
end
