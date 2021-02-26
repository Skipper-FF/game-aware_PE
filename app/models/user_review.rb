class UserReview < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :age, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :rating, presence: true
end
