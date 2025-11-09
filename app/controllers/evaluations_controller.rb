class EvaluationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:id])
    kind = params[:kind]

    evaluation = @post.evaluations.find_by(user: current_user, kind: kind)

    if evaluation
      evaluation.destroy
    else
      @post.evaluations.create(user: current_user, kind: kind)
    end

    respond_to do |format|
      format.js
      format.html { redirect_to @post } # fallback
    end
  end
end