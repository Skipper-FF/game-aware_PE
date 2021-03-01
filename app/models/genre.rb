class Genre < ApplicationRecord
  has_many :game_genre
  has_many :games, through: :game_genres
end
