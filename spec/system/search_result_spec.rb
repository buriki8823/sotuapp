require 'rails_helper'

RSpec.describe "Search result partial", type: :system do
  let!(:user) do
    create(:user,
      name: "投稿者A",
      email: "user@example.com",
      password: "password",
      avatar_url: nil
    )
  end

  let!(:post_with_image) do
    create(:post,
      title: "画像あり投稿",
      body: "本文",
      user: user,
      image_urls: ["http://example.com/test.png"],
      rating_enabled: true
    )
  end

  let!(:post_without_image) do
    create(:post,
      title: "画像なし投稿",
      body: "本文",
      user: user,
      image_urls: ["no_image.png"] 
    )
  end

  before do
    driven_by :selenium_chrome_headless
    login_as(user, scope: :user)
  end

  it "shows user avatar and name", js: true do
    visit posts_path
    expect(page).to have_selector("img.rounded-circle")
    expect(page).to have_content("投稿者：#{user.name}")
  end

  it "shows post image when present", js: true do
    visit posts_path
    expect(page).to have_selector("img[src*='http://example.com/test.png']")
  end

  it "shows no_image.png when image_urls contains only no_image.png", js: true do
    visit posts_path
    # ビューは else に入らないので、投稿画像として no_image.png が出る
    expect(page).to have_selector("img[src*='no_image']")
  end

  it "links to post detail page", js: true do
    visit posts_path
    expect(page).to have_link(href: post_path(post_with_image))
  end
end