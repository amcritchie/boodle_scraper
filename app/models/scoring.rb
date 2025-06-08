class Scoring < ApplicationRecord
  belongs_to :game
  has_many :periods, dependent: :destroy

  validates :home_points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :away_points, presence: true, numericality: { greater_than_or_equal_to: 0 }
end 