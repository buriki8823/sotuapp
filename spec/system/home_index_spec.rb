require 'rails_helper'

RSpec.describe "Home index page", type: :system do
  let!(:user) do
    User.create!(
      name: "翔",
      email: "test@example.com",
      password: "password"
    )
  end

  let!(:post) do
    Post.create!(
      title: "テスト投稿",
      body: "本文テスト",
      user: user,
      image_urls: [ "https://example.com/test.png" ]
    )
  end

  before do
    driven_by(:rack_test)
    login_as(user, scope: :user)
  end

  it "shows navigation cards" do
    visit root_path
    expect(page).to have_link("マイページ", href: mypage_path)
    expect(page).to have_link("投稿", href: new_post_path)
    expect(page).to have_link("ブックマーク", href: bookmarks_path)
  end

  it "shows 投稿一覧 button and search bar" do
    visit root_path
    expect(page).to have_link("投稿一覧", href: posts_path)
    expect(page).to have_field("q", placeholder: "タイトルまたはアカウント名を入力")
    # 検索ボタンはラベルがないので class で指定
    expect(page).to have_selector("form[action='#{search_path}'] button.btn.btn-light")
  end

  it "shows posts when present" do
    visit root_path
    # タイトルが描画されていないので投稿者名で確認
    expect(page).to have_content("投稿者：翔")
    # リンクテキストではなく href で確認
    expect(page).to have_selector("a[href='#{post_path(post)}']")
  end

  it "shows message when no posts" do
    Post.delete_all
    visit root_path
    expect(page).to have_content("該当する投稿は見つかりませんでした。")
  end

  it "can search posts by title" do
    visit root_path
    fill_in "q", with: "テスト投稿"
    # 検索フォーム内のボタンを限定してクリック
    within("form[action='#{search_path}']") do
      find("button.btn.btn-light").click
    end
    expect(page).to have_content("投稿者：翔")
  end
end
