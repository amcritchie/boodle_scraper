class MatchupsController < ApplicationController
  def week1
    @matchups = Matchup.where(season: 2025, week_slug: 1).order(passing_offense_score: :desc)
    
    # Get all teams seasons data for rankings
    @teams_seasons = TeamsSeason.where(season_year: 2025).includes(:team).order(:team_slug)
  end

  def roster
    @matchups = Matchup.where(season: 2025, week_slug: 1).order(:team_slug)
  end

  def summary
    @matchups = Matchup.where(season: 2025, week_slug: 1).order(passing_offense_score: :desc)
    
    # Get all teams seasons data for component rankings
    @teams_seasons = TeamsSeason.where(season_year: 2025).includes(:team).order(:team_slug)
    
    # Get component rankings for the tables
    @play_caller_rankings = TeamsSeason.where(season_year: 2025).play_callers.by_play_caller_rank
    @qb_passing_rankings = TeamsSeason.where(season_year: 2025).qbs.by_grades_offense
    @receiving_rankings = TeamsSeason.where(season_year: 2025).receiver_rankings
    @pass_block_rankings = TeamsSeason.where(season_year: 2025).pass_block_rankings
    @pass_rush_rankings = TeamsSeason.where(season_year: 2025).pass_rush_rankings
    @coverage_rankings = TeamsSeason.where(season_year: 2025).coverage_rankings
    @rushing_rankings = TeamsSeason.where(season_year: 2025).rushing_rankings
    @run_block_rankings = TeamsSeason.where(season_year: 2025).run_block_rankings
    @run_defense_rankings = TeamsSeason.where(season_year: 2025).run_defense_rankings
  end

  def teams_seasons
    @teams_seasons = TeamsSeason.where(season_year: 2025).includes(:team).order(:team_slug)
    # Ranking data for tables
    @play_caller_rankings = TeamsSeason.where(season_year: 2025).play_callers.by_play_caller_rank
    @pace_rankings        = TeamsSeason.where(season_year: 2025).play_callers.by_pace_rank
    @run_heavy_rankings   = TeamsSeason.where(season_year: 2025).play_callers.by_run_heavy_rank
    @qb_passing_rankings  = TeamsSeason.where(season_year: 2025).qbs.by_grades_offense
    @receiving_rankings   = TeamsSeason.where(season_year: 2025).receiver_rankings
    @pass_block_rankings  = TeamsSeason.where(season_year: 2025).pass_block_rankings
    @pass_rush_rankings   = TeamsSeason.where(season_year: 2025).pass_rush_rankings
    @coverage_rankings    = TeamsSeason.where(season_year: 2025).coverage_rankings
    @rushing_rankings     = TeamsSeason.where(season_year: 2025).rushing_rankings
    @run_block_rankings   = TeamsSeason.where(season_year: 2025).run_block_rankings
    @run_defense_rankings = TeamsSeason.where(season_year: 2025).run_defense_rankings
  end

  def rankings
    @play_caller_rankings = TeamsSeason.where(season_year: 2025).play_callers.by_play_caller_rank
    @pace_rankings        = TeamsSeason.where(season_year: 2025).play_callers.by_pace_rank
    @run_heavy_rankings   = TeamsSeason.where(season_year: 2025).play_callers.by_run_heavy_rank
    @qb_passing_rankings  = TeamsSeason.where(season_year: 2025).qbs.by_grades_offense
    @receiving_rankings   = TeamsSeason.where(season_year: 2025).receiver_rankings
    @pass_block_rankings  = TeamsSeason.where(season_year: 2025).pass_block_rankings
    @pass_rush_rankings   = TeamsSeason.where(season_year: 2025).pass_rush_rankings
    @coverage_rankings    = TeamsSeason.where(season_year: 2025).coverage_rankings
    @rushing_rankings     = TeamsSeason.where(season_year: 2025).rushing_rankings
    @run_block_rankings   = TeamsSeason.where(season_year: 2025).run_block_rankings
    @run_defense_rankings = TeamsSeason.where(season_year: 2025).run_defense_rankings
  end
end
