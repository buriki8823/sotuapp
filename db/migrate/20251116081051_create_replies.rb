class CreateReplies < ActiveRecord::Migration[7.2]
  def change
    create_table :replies do |t|
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.references :message, null: false, foreign_key: true
      t.integer :recipient_id

      t.timestamps
    end
  end
end
