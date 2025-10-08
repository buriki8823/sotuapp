class HomeController < ApplicationController
  def index
    @posts = Post.order("RANDOM()").limit(5)
  end
end
