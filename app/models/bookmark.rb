class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id }

  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :for_post, ->(post) { where(post_id: post.id) }
end
