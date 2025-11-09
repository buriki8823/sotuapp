class StarRatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    post = Post.find(params[:post_id])
    return head :forbidden unless post.rating_enabled?

    rating = current_user.star_ratings.find_or_initialize_by(post_id: post.id)
    rating.score = params[:score]

    if rating.save
      render json: { new_average_score: post.average_star_score }
    else
      render json: { error: "保存に失敗しました" }, status: :unprocessable_entity
    end
  end
end