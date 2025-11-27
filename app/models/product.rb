class Product < ApplicationRecord
  belongs_to :post

  def to_param
    uuid
  end
end
