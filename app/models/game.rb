class Game < ApplicationRecord

  include PgSearch::Model
  pg_search_scope :search_by_name,
    against: [:name, :alternative_names],
    using: {
      tsearch: { prefix: true }
    }

  has_many :game_content_descriptors, dependent: :destroy
  has_many :game_interactive_elements, dependent: :destroy
  has_many :esrb_content_descriptors, through: :game_content_descriptors
  has_many :esrb_interactive_elements, through: :game_interactive_elements
  has_many :user_reviews, dependent: :destroy
  has_many :game_genres, dependent: :destroy
  has_many :genres, through: :game_genres
  belongs_to :esrb_rating_category
end
