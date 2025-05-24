class Matchup < ApplicationRecord
  validates :season, :week, :game, :home_team, :away_team, presence: true

  # Add methods to fetch offensive and defensive lineups if needed
end
