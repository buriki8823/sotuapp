class AddUuidToRooms < ActiveRecord::Migration[7.2]
  def change
    add_column :rooms, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_index  :rooms, :uuid, unique: true
  end
end
