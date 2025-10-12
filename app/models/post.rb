class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :bookmarks
  has_many :bookmarked_users, through: :bookmarks, source: :user
  has_many :products, dependent: :destroy
  accepts_nested_attributes_for :products
  has_many :comments, dependent: :destroy


  validate :images_count_within_limit

  private

  def images_count_within_limit
    if images.attachments.size > 5
      errors.add(:images, "は最大5枚までです")
    end
  end
end
