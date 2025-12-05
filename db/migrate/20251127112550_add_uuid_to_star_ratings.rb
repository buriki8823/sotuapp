class AddUuidToStarRatings < ActiveRecord::Migration[7.2]
  def change
    add_column :star_ratings, :uuid, :uuid, default: "gen_random_uuid()", null: false
   add_index :star_ratings, :uuid, unique: true
  end
end
