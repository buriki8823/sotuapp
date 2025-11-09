class CreateStarRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :star_ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.integer :score, null: false
      t.timestamps
    end
  end
end
