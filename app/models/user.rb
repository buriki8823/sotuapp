class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts
  has_one_attached :avatar
  has_one_attached :mypage_background_image
  has_one_attached :window_background_image

  has_many :bookmarks
  has_many :bookmarked_posts, through: :bookmarks, source: :post
  has_many :comments

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  validate :password_uniqueness_across_users, if: -> { password.present? }

 def password_uniqueness_across_users
   encrypted = Devise::Encryptor.digest(User, password)
   if User.where(encrypted_password: encrypted).exists?
    errors.add(:password, :taken_password)
   end
 end

 validate :password_not_blank_only

 def password_not_blank_only
   if password.present? && password.strip.empty?
     errors.add(:password, :blank_only)
   end
 end
end
