class MatchupsController < ApplicationController
  def week1
    @matchups = Matchup.where(season: 2025, week: 1).order(passer_score: :desc)
  end
end
