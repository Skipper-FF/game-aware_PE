class AddAgeToEsrbRatingCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :esrb_rating_categories, :age, :integer
  end
end
