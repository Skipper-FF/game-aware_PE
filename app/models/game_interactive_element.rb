class GameInteractiveElement < ApplicationRecord
  belongs_to :game
  belongs_to :esrb_interactive_element
end
