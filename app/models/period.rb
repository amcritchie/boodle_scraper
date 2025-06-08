class Period < ApplicationRecord
  belongs_to :scoring

  validates :period_type, presence: true
  validates :number, presence: true, numericality: { greater_than: 0 }
  validates :sequence, presence: true
  validates :home_points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :away_points, presence: true, numericality: { greater_than_or_equal_to: 0 }
end 