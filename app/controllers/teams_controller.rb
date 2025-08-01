class TeamsController < ApplicationController
  def rankings
    @year = params[:year]
    @teams_weeks      = TeamsWeek.where(season_year: @year).includes(:team)  
    @play_caller_rankings = @teams_weeks.order(:offensive_play_caller_rank)
    @offensive_play_caller_rankings = @teams_weeks.order(:offensive_play_caller_rank)
    @defensive_play_caller_rankings = @teams_weeks.order(:defensive_play_caller_rank)
    @pace_rankings        = @teams_weeks.order(:pace_of_play_rank)
    @run_heavy_rankings   = @teams_weeks.order(:run_heavy_rank)
    @qb_passing_rankings  = @teams_weeks.order(:qb_passing_rank)
    @receiving_rankings   = @teams_weeks.order(:receiver_core_rank)
    @pass_block_rankings  = @teams_weeks.order(:pass_block_rank)
    @pass_rush_rankings   = @teams_weeks.order(:pass_rush_rank)
    @coverage_rankings    = @teams_weeks.order(:coverage_rank)
    @rushing_rankings     = @teams_weeks.order(:rushing_rank)
    @run_block_rankings   = @teams_weeks.order(:rush_block_rank)
    @run_defense_rankings = @teams_weeks.order(:run_defense_rank)


  end

  def power_rankings
    @year = params[:year]
    # Calculate power rankings for all teams using TeamsWeek
    @teams_weeks      = TeamsWeek.where(season_year: @year).includes(:team)  
    @power_rankings   = @teams_weeks.order(:power_rank_score)
    @offense_rankings = @teams_weeks.order(:offense_score)
    @defense_rankings = @teams_weeks.order(:defense_score)
  end
      
  def teams_seasons
    @year = params[:year]
    @teams_seasons = TeamsSeason.where(season_year: @year).includes(:team).order(:team_slug)
    # Ranking data for tables
    # @play_caller_rankings = Coach.where(slug: TeamsSeason.where(season_year: 2025).pluck(:offensive_play_caller).flatten.compact).by_play_caller_rank
    @play_caller_rankings = TeamsSeason.where(season_year: @year).offensive_play_callers.by_play_caller_rank
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