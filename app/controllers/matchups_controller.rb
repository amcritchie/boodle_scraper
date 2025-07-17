class MatchupsController < ApplicationController
  def week1
    @matchups = Matchup.where(season: 2025, week_slug: 1).order(passer_score: :desc)
  end

  def roster
    @matchups = Matchup.where(season: 2025, week_slug: 1).order(:team_slug)
  end
end
