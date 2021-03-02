class Kid < ApplicationRecord
  belongs_to :user

  def age
    (Date.today - birthdate).to_i / 365
  end

  def recommended_games
    Game
      .joins(:esrb_rating_category)
      .where("esrb_rating_categories.age <= ?", age)
      .by_random
      .limit(3)
  end
end
