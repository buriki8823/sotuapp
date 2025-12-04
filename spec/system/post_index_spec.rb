require 'rails_helper'

RSpec.describe "Posts index page", type: :system do
  let(:user) { User.create!(email: "test@example.com", password: "password", name: "テストユーザー") }

  before do
    driven_by(:rack_test)
    login_as(user, scope: :user)
  end

  it "displays a list of posts" do
    create(:post, user: user, title: "投稿1", body: "本文1")
    create(:post, user: user, title: "投稿2", body: "本文2")

    visit posts_path
    expect(page).to have_content("投稿1")
    expect(page).to have_content("投稿2")
  end

  it "allows sorting by cute" do
    post1 = create(:post, user: user, title: "投稿1", body: "本文1")
    post2 = create(:post, user: user, title: "投稿2", body: "本文2")
    post2.evaluations.create!(user: user, kind: "cute")

    visit posts_path(sort: "cute")
    expect(page).to have_content("投稿2")
  end

  it "shows pagination" do
    25.times do |i|
      create(:post, user: user, title: "投稿#{i}", body: "本文#{i}")
    end

    visit posts_path
    # kaminari の場合は ul.pagination が出力される
    expect(page).to have_link("2")
  end
end