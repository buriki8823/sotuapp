class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :bookmarks
  has_many :bookmarked_users, through: :bookmarks, source: :user
  has_many :products, dependent: :destroy
  accepts_nested_attributes_for :products


  validate :must_have_valid_images

  private

  def must_have_valid_images
    valid_urls = image_urls.reject(&:blank?) if image_urls.is_a?(Array)

    if valid_urls.blank?
      errors.add(:image_urls, "を1枚以上挿入してください")
    elsif valid_urls.size > 5
      errors.add(:image_urls, "は最大5枚までです")
    end
  end
end
