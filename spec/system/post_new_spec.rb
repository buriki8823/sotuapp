require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let(:user) do
    User.create!(
      email: "test@example.com",
      password: "password",
      name: "テストユーザー",        # name 必須
    )
  end

  before do
    driven_by(:rack_test) # JS不要ならrack_test、必要ならselenium_chrome_headless
    login_as(user, scope: :user)
  end

  it "creates a post successfully" do
    visit new_post_path
    fill_in "タイトル", with: "テスト投稿"
    fill_in "概要", with: "これはシステムテスト用の投稿です"
    find("#image-url-0", visible: false).set("https://via.placeholder.com/800x600.png?text=Test+Image")

    click_button "投稿する"

    expect(page).to have_content("テスト投稿")
    expect(page).to have_content("これはシステムテスト用の投稿です")
  end

  it "shows error when title is missing" do
    visit new_post_path
    fill_in "概要", with: "タイトルなしの投稿"
    find("#image-url-0", visible: false).set("https://via.placeholder.com/800x600.png?text=Test+Image")

    click_button "投稿する"

    expect(page).to have_content("投稿に失敗しました。入力内容を確認してください。")
  end

  it "shows error when no image is provided" do
    visit new_post_path
    fill_in "タイトル", with: "画像なし投稿"
    fill_in "概要", with: "画像がない投稿"

    click_button "投稿する"

    expect(page).to have_content("投稿に失敗しました。入力内容を確認してください。")
  end
end