class EsrbRatingCategory < ApplicationRecord
  has_many :games, dependent: :destroy

  # AGE_RATINGS = {
  #   '1'  => 'Everyone',
  #   '2'  => 'Everyone',
  #   '3'  => 'Everyone',
  #   '4'  => 'Everyone',
  #   '5'  => 'Everyone',
  #   '6'  => 'Everyone',
  #   '7'  => 'Everyone',
  #   '8'  => 'Everyone',
  #   '9'  => 'Everyone',
  #   '8'  => 'Everyone',
  #   '9'  => 'Everyone',
  #   '10' => ['Everyone', 'Everyone 10+'],
  #   '11' => ['Everyone', 'Everyone 10+'],
  #   '12' => ['Everyone', 'Everyone 10+'],
  #   '13' => ['Everyone', 'Everyone 10+', "Teen"],
  #   '14' => ['Everyone', 'Everyone 10+', "Teen"],
  #   '15' => ['Everyone', 'Everyone 10+', "Teen"],
  #   '16' => ['Everyone', 'Everyone 10+', "Teen"],
  #   '17' => ['Everyone', 'Everyone 10+', "Teen", "Mature 17+"],
  #   '18' => ['Everyone', 'Everyone 10+', "Adults Only 18+", "Teen", "Mature 17+", "Rating Pending", "N/C"]
  # }
end

# appel constante :
# EsrbRatingCategory::AGE_RATINGS
