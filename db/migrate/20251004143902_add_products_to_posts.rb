class AddProductsToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :products, :json
  end
end
