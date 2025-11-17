class CreateEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :entries do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :partner_id
      t.string :room_id

      t.timestamps
    end
  end
end
