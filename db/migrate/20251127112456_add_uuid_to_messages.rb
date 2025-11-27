class AddUuidToMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :messages, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_index  :messages, :uuid, unique: true
  end
end
