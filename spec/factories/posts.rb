FactoryBot.define do
  factory :post do
    association :user
    title   { "テスト投稿" }
    body    { "これはテスト用の本文です" }
    caption { "テストキャプション" }
    rating_enabled { true }

    # デフォルトは画像あり（ダミーURL）
    image_urls { ["https://via.placeholder.com/800x600.png?text=Test+Image"] }

    trait :with_image do
      image_urls { ["https://via.placeholder.com/800x600.png?text=With+Image"] }
    end

    trait :without_image do
      # プレースホルダーもダミーURLに統一
      image_urls { ["https://via.placeholder.com/600x400.png?text=No+Image"] }
    end
  end
end