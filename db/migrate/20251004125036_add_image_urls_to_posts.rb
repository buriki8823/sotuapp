class AddImageUrlsToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :image_urls, :json
  end
end
