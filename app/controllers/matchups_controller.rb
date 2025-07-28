class MatchupsController < ApplicationController
  def week1
    # Use cached passing_attack_score for ranking
    @matchups = Matchup.where(season: 2025, week_slug: 1).order(passing_attack_score: :desc)
    
    # Get all teams seasons data for rankings
    @teams_seasons = TeamsSeason.where(season_year: 2025).includes(:team).order(:team_slug)
  end

  def roster
    @matchups = Matchup.where(season: 2025, week_slug: 1).order(:team_slug)
  end

  def summary
    # Use cached values for ranking - passing_attack_score and rushing_attack_score
    @matchups = Matchup.where(season: 2025, week_slug: 1)
  end




end
