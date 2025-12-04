FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    sequence(:password) { |n| "password#{n}" }
    sequence(:name) { |n| "テストユーザー#{n}" }
    avatar_url { "default_avatar.png" }
  end
end