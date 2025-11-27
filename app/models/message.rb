class Message < ApplicationRecord
  has_many :replies, dependent: :destroy

  belongs_to :user
  belongs_to :room
  belongs_to :recipient, class_name: "User"

  validates :subject, length: { maximum: 100 }
  validates :body, presence: true, length: { maximum: 1000 }
  validates :recipient_id, presence: true
  validate :recipient_must_exist
  validate :cannot_send_to_self
  validates :room_id, presence: true
  validate :room_must_exist



  def mark_as_read_by(viewer)
    update(read: true) if user_id != viewer.id
  end

  def cannot_send_to_self
    if user_id == recipient_id
      errors.add(:recipient_id, "に自分自身を指定することはできません")
    end
  end

  def to_param
    uuid
  end

  private 
  
  def recipient_must_exist
    errors.add(:recipient_id, "が存在しません") unless User.exists?(recipient_id)
  end

  def room_must_exist
    errors.add(:room_id, "が存在しません") unless Room.exists?(room_id)
  end
end
