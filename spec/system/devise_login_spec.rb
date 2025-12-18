require 'rails_helper'

RSpec.describe "Devise login page", type: :system do
  let!(:user) do
    User.create!(
      name: "テストユーザー",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password",
      uuid: SecureRandom.uuid,
      avatar_url: "https://example.com/avatar.png"
    )
  end

  # JS不要なので rack_test に戻す
  before do
    driven_by(:rack_test)
  end

  it "shows login form" do
    visit new_user_session_path
    expect(page).to have_field("メールアドレス")
    expect(page).to have_field("パスワード")
    expect(page).to have_button("ログイン")
  end

  it "logs in successfully with valid credentials" do
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログイン"

    # rack_testならラベルで拾えるのでこれで安定
    expect(page).to have_button("ログアウト")
    expect(page).to have_content("マイページ")
  end

  it "fails to log in with invalid credentials" do
    visit new_user_session_path
    fill_in "メールアドレス", with: "wrong@example.com"
    fill_in "パスワード", with: "wrongpass"
    click_button "ログイン"

    # フォームが再表示されることを確認
    expect(page).to have_field("メールアドレス")
    expect(page).to have_button("ログイン")
  end

  it "has links to sign up and forgot password" do
    visit new_user_session_path
    expect(page).to have_link("新規登録", href: new_user_registration_path)
    expect(page).to have_link("こちら", href: new_user_password_path)
  end

  it "has a Google login button" do
    visit new_user_session_path
    expect(page).to have_link("Google でログイン", href: user_google_oauth2_omniauth_authorize_path)
  end
end
