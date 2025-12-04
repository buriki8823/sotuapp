require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is invalid without email" do
      user = User.new(email: nil, password: "password")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "is invalid without password" do
      user = User.new(email: "test@example.com", password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "is invalid with duplicate email" do
      User.create!(email: "test@example.com", password: "password", name: "First")
      user = User.new(email: "test@example.com", password: "password", name: "Second")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "is valid with email and password" do
      user = User.new(email: "valid@example.com", password: "password", name: "Valid")
      expect(user).to be_valid
    end
  end

  describe "Devise modules" do
    it "responds to database_authenticatable" do
      user = User.new(email: "test@example.com", password: "password")
      expect(user).to respond_to(:valid_password?)
    end

    it "responds to rememberable" do
      user = User.create!(email: "test@example.com", password: "password", name: "Test")
      expect(user).to respond_to(:remember_me)
    end

    it "responds to recoverable" do
      user = User.create!(email: "test@example.com", password: "password", name: "Test")
      expect(user).to respond_to(:send_reset_password_instructions)
    end
  end

  describe "validations for registration" do
    it "is invalid without name when provider is blank" do
      user = User.new(name: nil, email: "test@example.com", password: "password", provider: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it "allows blank name when provider is present (Google login)" do
      user = User.new(name: nil, email: "google@example.com", password: "password", provider: "google_oauth2")
      expect(user).to be_valid
    end

    it "is invalid with short password" do
      user = User.new(name: "テストユーザー", email: "test@example.com", password: "123")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "is invalid if password is only blank spaces" do
      user = User.new(name: "Blank", email: "blank@example.com", password: "   ")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "is valid with name, email and password" do
      user = User.new(name: "テストユーザー", email: "valid@example.com", password: "password")
      expect(user).to be_valid
    end

    it "accepts avatar_url" do
      user = User.new(name: "テストユーザー", email: "avatar@example.com", password: "password", avatar_url: "http://example.com/avatar.png")
      expect(user).to be_valid
      expect(user.avatar_url).to eq("http://example.com/avatar.png")
    end
  end

  describe "password reset (recoverable)" do
    let!(:user) { User.create!(name: "Test", email: "test@example.com", password: "password") }

    it "sends reset password instructions" do
      expect {
        user.send_reset_password_instructions
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "returns user when email exists" do
      found = User.send_reset_password_instructions(email: "test@example.com")
      expect(found).to eq(user)
    end
  end

  describe "omniauth" do
    it "creates user from omniauth data" do
      auth = OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "12345",
        info: { email: "google@example.com", name: "Googleユーザー" }
      )
      user = User.from_omniauth(auth)
      expect(user.email).to eq("google@example.com")
      expect(user.name).to eq("Googleユーザー")
    end
  end

  describe "utility methods" do
    it "returns default avatar url when none is set" do
      user = User.new(name: "NoAvatar", email: "noavatar@example.com", password: "password")
      expect(user.avatar_url_or_default).to eq("default_avatar.png")
    end

    it "returns given avatar_url when present" do
      user = User.new(name: "Avatar", email: "avatar@example.com", password: "password", avatar_url: "http://example.com/avatar.png")
      expect(user.avatar_url_or_default).to eq("http://example.com/avatar.png")
    end

    it "returns uuid in to_param" do
      user = User.create!(name: "UUIDUser", email: "uuid@example.com", password: "password")
      expect(user.to_param).to eq(user.uuid)
    end
  end

  describe "password update validations" do
    let!(:user) { User.create!(name: "Test", email: "test@example.com", password: "oldpassword") }

    it "is invalid if new password is too short" do
      user.password = "123"
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "is invalid if new password is blank only" do
      user.password = "   "
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "is valid with proper new password" do
      user.password = "newsecurepassword"
      expect(user).to be_valid
    end
  end

  describe "mypage background and avatar methods" do
    let(:user) { User.new(name: "Test", email: "test@example.com", password: "password") }

    it "returns default avatar when none is set" do
      expect(user.avatar_url_or_default).to eq("default_avatar.png")
    end

    it "returns given avatar_url when present" do
      user.avatar_url = "http://example.com/avatar.png"
      expect(user.avatar_url_or_default).to eq("http://example.com/avatar.png")
    end

    it "returns nil for mypage_background_url_or_default if none is set" do
      expect(user.mypage_background_url_or_default).to be_nil
    end

    it "returns nil for window_background_url_or_default if none is set" do
      expect(user.window_background_url_or_default).to be_nil
    end
  end
end