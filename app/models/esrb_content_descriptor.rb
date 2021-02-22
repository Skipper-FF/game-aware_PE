class EsrbContentDescriptor < ApplicationRecord
  has_many :game_content_descriptors
  has_many :games, through: :game_content_descriptor
end
