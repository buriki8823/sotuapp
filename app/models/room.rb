class Room < ApplicationRecord
    has_many :entries
    has_many :messages

    def to_param
      uuid
    end
end
