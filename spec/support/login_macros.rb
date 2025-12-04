module LoginMacros
  def sign_in_as(user)
    visit "/test_login?user_id=#{user.id}"
  end
end

RSpec.configure do |config|
  config.include LoginMacros, type: :system
end
