class EsrbInteractiveElement < ApplicationRecord
  has_many :game_interactive_elements
  has_many :games, through: :game_interactive_elements
end
