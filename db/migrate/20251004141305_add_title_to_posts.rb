class AddTitleToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :title, :string
  end
end
