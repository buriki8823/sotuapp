class AddSubjectToMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :messages, :subject, :string
    add_column :messages, :read, :boolean, default: false, null: false
  end
end
