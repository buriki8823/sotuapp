require 'rails_helper'

RSpec.describe "Password edit page", type: :system do
  let!(:user) { User.create!(name: "Test", email: "test@example.com", password: "oldpassword") }

  before do
    driven_by(:rack_test)
    # Devise のパスワードリセットトークンを生成
    token = user.send_reset_password_instructions
    @reset_path = edit_user_password_path(reset_password_token: token)
  end

  it "shows password edit form" do
    visit @reset_path
    expect(page).to have_content("パスワードをリセットしますか？")
    expect(page).to have_field("新しいパスワード")
    expect(page).to have_field("新しいパスワード（確認）")
    expect(page).to have_button("パスワードを変更")
  end

  it "updates password successfully with valid data" do
    visit @reset_path
    fill_in "新しいパスワード", with: "newpassword"
    fill_in "新しいパスワード（確認）", with: "newpassword"
    click_button "パスワードを変更"

    # 非表示テキストも含めて確認
    expect(page).to have_selector(:xpath, "//*[contains(text(), 'パスワードが正常に変更されました。')]", visible: :all)
  end

  it "shows error with mismatched confirmation" do
    visit @reset_path
    fill_in "新しいパスワード", with: "newpassword"
    fill_in "新しいパスワード（確認）", with: "wrongpassword"
    click_button "パスワードを変更"

    # 実際の文言に合わせる（スペースあり）
    expect(page).to have_content("パスワード確認 が一致しません")
  end

  it "shows error with short password" do
    visit @reset_path
    fill_in "新しいパスワード", with: "123"
    fill_in "新しいパスワード（確認）", with: "123"
    click_button "パスワードを変更"

    # 実際の文言に合わせる（スペースあり）
    expect(page).to have_content("パスワード は6文字以上で入力してください")
  end
end