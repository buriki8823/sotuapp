class AddNameHiraToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :name_hira, :string
  end
end
