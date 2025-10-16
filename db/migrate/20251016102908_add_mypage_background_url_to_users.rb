class AddMypageBackgroundUrlToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :mypage_background_url, :string
    add_column :users, :window_background_url, :string
  end
end
