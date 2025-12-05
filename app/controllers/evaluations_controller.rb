class EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    kind = params[:kind]
    evaluation = @post.evaluations.find_by(user: current_user, kind: kind)

    if evaluation
      evaluation.destroy
      render json: { status: "unevaluated", kind: kind }, status: :ok
    else
      @post.evaluations.create(user: current_user, kind: kind)
      render json: { status: "evaluated", kind: kind }, status: :created
    end
  end

  private

  def set_post
    @post = Post.find_by(uuid: params[:id])
  end
end
