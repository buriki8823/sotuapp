class Evaluation < ApplicationRecord
  belongs_to :post
  belongs_to :user

  enum kind: {
    cool: 0,
    cute: 1,
    stylish: 2,
    healing: 3,
    aesthetic: 4
  }

  validates :kind, presence: true
end