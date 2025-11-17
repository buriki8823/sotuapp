class ChangeRoomIdToBigintInEntries < ActiveRecord::Migration[7.2]
  def change
    change_column :entries, :room_id, :bigint, using: 'room_id::bigint'
  end
end
