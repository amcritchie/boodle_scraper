class Venue < ApplicationRecord
  has_many :games

  validates :name, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :country, presence: true
end 