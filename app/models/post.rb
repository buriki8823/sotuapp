class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :bookmarks
  has_many :bookmarked_users, through: :bookmarks, source: :user
end
