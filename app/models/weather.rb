class Weather < ApplicationRecord
  belongs_to :game

  validates :condition, presence: true
  validates :temperature, presence: true
  validates :wind_speed, presence: true
  validates :wind_direction, presence: true
end 