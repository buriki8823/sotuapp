class AddReadToReplies < ActiveRecord::Migration[7.2]
  def change
    add_column :replies, :read, :boolean, default: false, null: false
  end
end
