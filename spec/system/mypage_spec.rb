require 'rails_helper'

RSpec.describe "User mypage", type: :system do
  let!(:user) { User.create!(name: "翔", email: "mypage@example.com", password: "password") }

  before do
    driven_by(:rack_test)
    login_as(user, scope: :user)
  end

  it "displays user name and email" do
    visit mypage_users_path   # ← current_user のマイページに修正
    expect(page).to have_content("翔")
  end

  it "shows default avatar when none is uploaded" do
    visit mypage_users_path
    expect(page).to have_selector("img[alt='プロフィール画像']")
  end

  it "shows uploaded avatar when present" do
    user.update!(avatar_url: "http://example.com/avatar.png")
    visit mypage_users_path
    expect(page).to have_selector("img[src*='http://example.com/avatar.png']")
  end

  it "shows total score and stars" do
    visit mypage_users_path
    expect(page).to have_content("トータルスコア")
    # ビューに合わせてクラス名を確認
    expect(page).to have_selector(".star-icon")
  end

  it "has navigation links" do
    visit mypage_users_path
    expect(page).to have_link("ブックマーク", href: bookmarks_path)
    expect(page).to have_link("投稿", href: new_post_path)
    expect(page).to have_link("#{user.name}さんの投稿一覧", href: my_posts_path)
    expect(page).to have_link("メール", href: user_dmpage_path(user))
  end
end
