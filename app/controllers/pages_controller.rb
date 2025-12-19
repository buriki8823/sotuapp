class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :terms, :privacy_policy, :tukaikata, :account, :login, :post, :bookmark, :mypage, :dm, :logout ]

  def terms
  end

  def privacy_policy
  end


  def tukaikata
  end

  def account
  end

  def login
  end

  def post
  end

  def bookmark
  end

  def mypage
  end

  def dm
  end

  def logout
  end
end
