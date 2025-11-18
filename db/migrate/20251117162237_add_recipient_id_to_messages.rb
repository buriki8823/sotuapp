class AddRecipientIdToMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :messages, :recipient_id, :integer
  end
end
