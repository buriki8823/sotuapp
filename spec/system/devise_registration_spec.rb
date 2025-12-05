require 'rails_helper'

RSpec.describe "User registration page", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows registration form" do
    visit new_user_registration_path
    expect(page).to have_field("アカウント名")
    expect(page).to have_field("メールアドレス")
    expect(page).to have_field("パスワード")
    expect(page).to have_field("パスワード確認")
    expect(page).to have_button("登録する")
  end

  it "registers successfully with valid data" do
    visit new_user_registration_path
    fill_in "アカウント名", with: "テストユーザー"
    fill_in "メールアドレス", with: "newuser@example.com"
    fill_in "パスワード", with: "password"
    fill_in "パスワード確認", with: "password"

    expect {
      click_button "登録する"
    }.to change(User, :count).by(1)

    # 非表示テキストも含めて確認
    expect(page).to have_selector(:xpath, "//*[contains(text(), '登録が完了しました')]", visible: :all)
    expect(User.find_by(email: "newuser@example.com")).to be_present
  end

  it "fails to register with invalid data" do
    visit new_user_registration_path
    fill_in "アカウント名", with: ""
    fill_in "メールアドレス", with: ""
    fill_in "パスワード", with: "short"
    fill_in "パスワード確認", with: "short"

    expect {
      click_button "登録する"
    }.not_to change(User, :count)

    # エラーメッセージが表示されていることを確認（ビューに出している場合）
    expect(page).to have_content("メールアドレス を入力してください")
    expect(page).to have_content("パスワード は6文字以上で入力してください")
    expect(page).to have_content("アカウント名 を入力してください")
  end
end
