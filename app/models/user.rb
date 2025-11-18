class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name.presence || "Googleユーザー"
      user.password = Devise.friendly_token[0, 20]
    end
  end


  has_many :posts
  has_many :star_ratings
  has_one_attached :avatar
  has_one_attached :mypage_background_image
  has_one_attached :window_background_image

  has_many :bookmarks
  has_many :bookmarked_posts, through: :bookmarks, source: :post
  has_many :comments
  has_many :entries
  has_many :messages

  validates :name, presence: true, unless: -> { provider.present? }

  validate :password_uniqueness_across_users, if: -> { password.present? && provider.blank? }

  def avatar_url_or_default
    avatar_url.presence || "default_avatar.png"
  end


  def password_uniqueness_across_users
    encrypted = Devise::Encryptor.digest(User, password)
    if User.where(encrypted_password: encrypted).exists?
     errors.add(:password, :taken_password)
    end
  end

  def mypage_background_url_or_default
    mypage_background_url.presence
  end

  def window_background_url_or_default
    window_background_url.presence
  end


  validate :password_not_blank_only

  def password_not_blank_only
    if password.present? && password.strip.empty?
      errors.add(:password, :blank_only)
    end
  end
end
