class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :message
  belongs_to :recipient, class_name: "User", optional: true
end
