require 'rails_helper'

RSpec.describe Bookmark, type: :model do
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
      body: "本文",
      user: user,
      image_urls: [ "https://example.com/test.png" ]
    )
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:post) }
  end

  describe "validations" do
    it "is valid with user and post" do
      bookmark = Bookmark.new(user: user, post: post)
      expect(bookmark).to be_valid
    end

    it "is invalid with duplicate user-post pair" do
      Bookmark.create!(user: user, post: post)
      duplicate = Bookmark.new(user: user, post: post)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end
  end

  describe "scopes" do
    let!(:bookmark) { Bookmark.create!(user: user, post: post) }

    it ".for_user returns bookmarks for given user" do
      expect(Bookmark.for_user(user)).to include(bookmark)
    end

    it ".for_post returns bookmarks for given post" do
      expect(Bookmark.for_post(post)).to include(bookmark)
    end
  end
end
