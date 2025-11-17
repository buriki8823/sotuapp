class ChangeUserIdTypeInEntries < ActiveRecord::Migration[7.2]
  def change
    change_column :entries, :user_id, :bigint, using: 'user_id::bigint'
    change_column :entries, :partner_id, :bigint, using: 'partner_id::bigint'
  end
end
