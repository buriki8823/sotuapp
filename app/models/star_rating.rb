class StarRating < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :score, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :post_id } # 同じ投稿に1回だけ評価

  def to_param
    uuid
  end
end
