class Game < ApplicationRecord
  has_many :game_content_descriptors
  has_many :game_interactive_elements
  has_many :esrb_content_descriptors, through: :game_content_descriptors
  has_many :esrb_interactive_elements, through: :game_interactive_elements
  has_many :user_reviews
  belongs_to :esrb_rating_category
end
