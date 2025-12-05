require 'rails_helper'

RSpec.describe "Password reset page", type: :system do
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

  before do
    driven_by(:rack_test)
  end

  it "shows password reset form" do
    visit new_user_password_path
    expect(page).to have_content("パスワードをリセットしますか？")
    expect(page).to have_field("メールアドレス")
    expect(page).to have_button("メールを送信")
  end

  it "sends reset instructions with valid email" do
    visit new_user_password_path
    fill_in "メールアドレス", with: "test@example.com"
    click_button "メールを送信"

    # 非表示テキストも含めて確認
    expect(page).to have_selector(:xpath, "//*[contains(text(), 'パスワード再設定の案内をメールで送信しました')]", visible: :all)
  end

  it "shows error with invalid email" do
    visit new_user_password_path
    fill_in "メールアドレス", with: "wrong@example.com"
    click_button "メールを送信"

    # 翻訳ファイルに not_found を追加して確認
    expect(page).to have_selector(:xpath, "//*[contains(text(), 'メールアドレスは見つかりませんでした')]", visible: :all)
  end

  it "has link back to login page" do
    visit new_user_password_path
    expect(page).to have_link("ログイン画面に戻る", href: new_user_session_path)
  end
end
