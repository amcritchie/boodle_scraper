class Roster < ApplicationRecord
#   belongs_to :team

  validates :season, :week, :game, :team, presence: true

  # Add methods to fetch offensive and defensive players if needed
end
