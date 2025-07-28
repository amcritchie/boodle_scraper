class MatchupsController < ApplicationController
  def week1
    @year = params[:year] || 2025
    # Use cached passing_attack_score for ranking
    @matchups = Matchup.where(season: @year, week_slug: 1).order(passing_attack_score: :desc)
    
    # Get all teams seasons data for rankings
    @teams_seasons = TeamsSeason.where(season_year: @year).includes(:team).order(:team_slug)
  end

  def roster
    @year = params[:year] || 2025
    @matchups = Matchup.where(season: @year, week_slug: 1).order(:team_slug)
  end

  def summary
    @year = params[:year] || 2025
    # Use cached values for ranking - passing_attack_score and rushing_attack_score
    @matchups = Matchup.where(season: @year, week_slug: 1)
  end
end
