class Entry < ApplicationRecord
  belongs_to :room
  belongs_to :user
  belongs_to :partner, class_name: 'User'

  validates :room_id, presence: true

  def to_param
    uuid
  end
end
