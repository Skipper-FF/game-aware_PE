class ModifyEsrbRatingCatForGames < ActiveRecord::Migration[6.0]
  def change
    change_column_null :games, :esrb_rating_category_id, true
  end
end
