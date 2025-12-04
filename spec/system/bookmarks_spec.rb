require 'rails_helper'

RSpec.describe "Bookmarks page", type: :system do
  let(:raw_password) { "password123" }

  let!(:user) do
    User.create!(
      name: "翔#{SecureRandom.hex(4)}",
      email: "test#{SecureRandom.hex(4)}@example.com",
      password: raw_password,
      password_confirmation: raw_password,
      uuid: SecureRandom.uuid,
      avatar_url: "https://example.com/avatar.png"
    )
  end

  let!(:post) do
    Post.create!(
      title: "ブックマーク投稿",
      body: "本文テスト",
      user: user,
      uuid: SecureRandom.uuid,
      image_urls: ["https://example.com/test.png"]
    )
  end

  context "when user has bookmarks" do
    before do
      driven_by(:rack_test)
      # rack_test では Warden ヘルパーで直接ログイン
      login_as(user, scope: :user)
      user.bookmarked_posts << post
    end

    it "shows bookmarked posts" do
      visit bookmarks_path
      expect(page).to have_content("ブックマーク一覧")
      expect(page).to have_content("ブックマーク投稿")
      expect(page).to have_content("投稿者：翔")
      expect(page).to have_selector("button.bookmark-remove-button")
    end

    it "links to post detail page" do
      visit bookmarks_path
      expect(page).to have_link(nil, href: post_path(post))
    end
  end

  context "when user has no bookmarks" do
    before do
      driven_by(:rack_test)
      login_as(user, scope: :user)
    end

    it "shows empty message and link to posts index" do
      visit bookmarks_path
      expect(page).to have_content("まだブックマークはありません。")
      expect(page).to have_link("投稿一覧を見る", href: posts_path)
    end
  end
end