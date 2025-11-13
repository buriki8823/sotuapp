class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:terms, :privacy_policy]

  def terms
  end

  def privacy_policy
  end

end
