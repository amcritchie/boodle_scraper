class Week < ApplicationRecord
  # belongs_to :season
  has_many :games

  # validates :sequence, presence: true, uniqueness: { scope: :season_year }
  # validates :title, presence: true
end 