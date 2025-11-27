class AddUuidToEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :entries, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_index  :entries, :uuid, unique: true
  end
end
