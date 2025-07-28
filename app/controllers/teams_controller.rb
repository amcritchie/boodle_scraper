class TeamsController < ApplicationController
  def rankings
    year = params[:year]
    @play_caller_rankings = Coach.where(slug: TeamsSeason.where(season_year: 2025).pluck(:offensive_play_caller).flatten.compact).by_play_caller_rank
    @play_caller_rankings = TeamsSeason.where(season_year: year)
    @play_caller_rankings = TeamsSeason.where(season_year: year).offensive_play_callers
    @play_caller_rankings = TeamsSeason.where(season_year: year).offensive_play_callers.by_play_caller_rank
    @pace_rankings        = TeamsSeason.where(season_year: year).offensive_play_callers.by_pace_rank
    @run_heavy_rankings   = TeamsSeason.where(season_year: year).offensive_play_callers.by_run_heavy_rank
    # @qb_passing_rankings  = TeamsSeason.where(season_year: year).qbs.by_grades_offense
    @qb_passing_rankings  = TeamsSeason.where(season_year: year).qb_rankings
    @receiving_rankings   = TeamsSeason.where(season_year: year).receiver_core_rankings
    @pass_block_rankings  = TeamsSeason.where(season_year: year).pass_block_rankings
    @pass_rush_rankings   = TeamsSeason.where(season_year: year).pass_rush_rankings
    @coverage_rankings    = TeamsSeason.where(season_year: year).coverage_rankings
    @rushing_rankings     = TeamsSeason.where(season_year: year).rushing_rankings
    @run_block_rankings   = TeamsSeason.where(season_year: year).run_block_rankings
    @run_defense_rankings = TeamsSeason.where(season_year: year).run_defense_rankings
  end

  def teams_seasons
    year = params[:year]
    @teams_seasons = TeamsSeason.where(season_year: year).includes(:team).order(:team_slug)
    # Ranking data for tables
    # @play_caller_rankings = Coach.where(slug: TeamsSeason.where(season_year: 2025).pluck(:offensive_play_caller).flatten.compact).by_play_caller_rank
    @play_caller_rankings = TeamsSeason.where(season_year: year).offensive_play_callers.by_play_caller_rank
    # @pace_rankings        = TeamsSeason.where(season_year: year).offensive_play_callers.by_pace_rank
    # @run_heavy_rankings   = TeamsSeason.where(season_year: year).offensive_play_callers.by_run_heavy_rank
    # @qb_passing_rankings  = TeamsSeason.where(season_year: year).qbs.by_grades_offense
    # @receiving_rankings   = TeamsSeason.where(season_year: year).receiver_rankings
    # @pass_block_rankings  = TeamsSeason.where(season_year: year).pass_block_rankings
    # @pass_rush_rankings   = TeamsSeason.where(season_year: year).pass_rush_rankings
    # @coverage_rankings    = TeamsSeason.where(season_year: year).coverage_rankings
    # @rushing_rankings     = TeamsSeason.where(season_year: year).rushing_rankings
    # @run_block_rankings   = TeamsSeason.where(season_year: year).run_block_rankings
    # @run_defense_rankings = TeamsSeason.where(season_year: year).run_defense_rankings
  end
end 