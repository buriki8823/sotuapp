require 'rails_helper'

RSpec.describe StarRating, type: :model do
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
      image_urls: [ "https://example.com/test.png" ] # ← 追加
    )
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  describe "validations" do
    it "is valid with score between 1 and 5" do
      rating = StarRating.new(user: user, post: post, score: 3)
      expect(rating).to be_valid
    end

    it "is invalid with score less than 1" do
      rating = StarRating.new(user: user, post: post, score: 0)
      expect(rating).not_to be_valid
      expect(rating.errors[:score]).to include("は一覧に含まれていません")
    end

    it "is invalid with score greater than 5" do
      rating = StarRating.new(user: user, post: post, score: 6)
      expect(rating).not_to be_valid
      expect(rating.errors[:score]).to include("は一覧に含まれていません")
    end

    it "is invalid when user rates the same post twice" do
      StarRating.create!(user: user, post: post, score: 4)
      duplicate = StarRating.new(user: user, post: post, score: 5)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("はすでに使用されています")
    end
  end

  describe "#to_param" do
    it "returns uuid instead of id" do
      rating = StarRating.create!(user: user, post: post, score: 5)
      expect(rating.to_param).to eq(rating.uuid)
    end
  end
end
