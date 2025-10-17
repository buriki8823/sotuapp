class Post < ApplicationRecord
  belongs_to :user
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_users, through: :bookmarks, source: :user
  has_many :products, dependent: :destroy
  accepts_nested_attributes_for :products
  has_many :comments, dependent: :destroy

  validate :must_have_valid_images

  def first_image_url_or_placeholder
    case image_urls
    when String
      urls = JSON.parse(image_urls) rescue []
    when Array
      urls = image_urls
    else
      urls = []
    end

    urls.first.presence || "placeholder.png"
  end

  private

  def must_have_valid_images
    urls = case image_urls
           when String then JSON.parse(image_urls) rescue []
           when Array then image_urls
           else []
           end

    valid_urls = urls.reject(&:blank?)

    if valid_urls.blank?
      errors.add(:image_urls, "を1枚以上挿入してください")
    elsif valid_urls.size > 5
      errors.add(:image_urls, "は最大5枚までです")
    end
  end
end