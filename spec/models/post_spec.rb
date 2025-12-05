require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { User.create!(name: "テストユーザー", email: "test@example.com", password: "password") }

  describe "validations" do
    it "is invalid without a title" do
      post = Post.new(user: user, title: nil, body: "概要", image_urls: [ "test.png" ])
      expect(post).not_to be_valid
      expect(post.errors[:title]).to be_present
    end

    it "is invalid if title is longer than 10 characters" do
      post = Post.new(user: user, title: "あいうえおかきくけこさ", body: "概要", image_urls: [ "test.png" ])
      expect(post.save(context: :create)).to be false   # createコンテキストを明示
      expect(post.errors[:title]).to include("は10文字以内で入力してください")
    end


    it "is invalid if body is longer than 200 characters" do
      long_body = "a" * 201
      post = Post.new(user: user, title: "タイトル", body: long_body, image_urls: [ "test.png" ])
      expect(post).not_to be_valid
      expect(post.errors[:body]).to include("は200文字以内で入力してください")
    end

    it "is invalid without at least one image" do
      post = Post.new(user: user, title: "タイトル", body: "概要", image_urls: [])
      expect(post).not_to be_valid
      expect(post.errors[:image_urls]).to include("を1枚以上挿入してください")
    end

    it "is invalid with more than 5 images" do
      urls = Array.new(6, "test.png")
      post = Post.new(user: user, title: "タイトル", body: "概要", image_urls: urls)
      expect(post).not_to be_valid
      expect(post.errors[:image_urls]).to include("は最大5枚までです")
    end
  end

  describe "#average_star_score" do
    it "returns 0 when no ratings exist" do
      post = Post.create!(user: user, title: "タイトル", body: "概要", image_urls: [ "test.png" ])
      expect(post.average_star_score).to eq(0)
    end

    it "returns average score rounded to 1 decimal" do
      post = Post.create!(user: user, title: "タイトル", body: "概要", image_urls: [ "test.png" ])
      user2 = User.create!(name: "別ユーザー", email: "other@example.com", password: "password")

      # 別ユーザーを使って2件の評価を作成
      post.star_ratings.create!(score: 3, user: user)
      post.star_ratings.create!(score: 4, user: user2)

      expect(post.average_star_score).to eq(3.5)
    end
  end

  describe "#first_image_url_or_placeholder" do
    it "returns first image url if present" do
      post = Post.new(user: user, title: "タイトル", body: "概要", image_urls: [ "test.png" ])
      expect(post.first_image_url_or_placeholder).to eq("test.png")
    end

    it "returns placeholder if no image" do
      post = Post.new(user: user, title: "タイトル", body: "概要", image_urls: [])
      expect(post.first_image_url_or_placeholder).to eq("placeholder.png")
    end
  end

  describe "scopes" do
    it "orders by total evaluations" do
      post1 = Post.create!(user: user, title: "A", body: "概要", image_urls: [ "a.png" ])
      post2 = Post.create!(user: user, title: "B", body: "概要", image_urls: [ "b.png" ])
      post2.evaluations.create!(user: user, kind: "cute")

      expect(Post.order_by_total_evaluations.first).to eq(post2)
    end
  end

  describe "#to_param" do
    it "returns uuid instead of id" do
      post = Post.create!(user: user, title: "タイトル", body: "概要", image_urls: [ "test.png" ])
      expect(post.to_param).to eq(post.uuid)
    end
  end

  describe "associations" do
    it "can have comments" do
      post = Post.create!(user: user, title: "タイトル", body: "概要", image_urls: [ "test.png" ])
      comment = post.comments.create!(user: user, body: "コメント本文")
      expect(post.comments).to include(comment)
    end

    it "can have bookmarks" do
      post = Post.create!(user: user, title: "タイトル", body: "概要", image_urls: [ "test.png" ])
      bookmark = post.bookmarks.create!(user: user)
      expect(post.bookmarked_users).to include(user)
    end

    it "can have products" do
      post = Post.create!(user: user, title: "タイトル", body: "概要", image_urls: [ "test.png" ])
      product = post.products.create!(title: "商品名", description: "説明", url: "http://example.com")
      expect(post.products).to include(product)
    end

    it "can have evaluations" do
      post = Post.create!(user: user, title: "タイトル", body: "概要", image_urls: [ "test.png" ])
      evaluation = post.evaluations.create!(user: user, kind: "cute")
      expect(post.evaluations).to include(evaluation)
    end
  end

  describe "scopes for index page" do
    it "orders posts by total evaluations" do
      post1 = Post.create!(user: user, title: "A", body: "概要", image_urls: [ "a.png" ])
      post2 = Post.create!(user: user, title: "B", body: "概要", image_urls: [ "b.png" ])
      post2.evaluations.create!(user: user, kind: "cute")

      expect(Post.order_by_total_evaluations.first).to eq(post2)
    end

    it "orders posts by specific kind (cute)" do
      post1 = Post.create!(user: user, title: "A", body: "概要", image_urls: [ "a.png" ])
      post2 = Post.create!(user: user, title: "B", body: "概要", image_urls: [ "b.png" ])
      post2.evaluations.create!(user: user, kind: "cute")

      expect(Post.order_by_kind(:cute).first).to eq(post2)
    end
  end
end
