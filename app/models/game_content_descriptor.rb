class GameContentDescriptor < ApplicationRecord
  belongs_to :game
  belongs_to :esrb_content_descriptor
end
