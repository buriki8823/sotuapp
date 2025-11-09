class AddRatingEnabledToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :rating_enabled, :boolean, default: true
  end
end
