class AddImagePublicIdToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :image_public_id, :string
  end
end
