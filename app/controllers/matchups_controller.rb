class MatchupsController < ApplicationController
  def week1
    @matchups = Matchup.where(season: 2025, week_slug: 1).order(passer_score: :desc)
  end

  def roster
    @matchups = Matchup.where(season: 2025, week_slug: 1).order(:team_slug)
  end

  def teams_seasons
    @teams_seasons = TeamsSeason.where(season_year: 2025).includes(:team).order(:team_slug)
    # Ranking data for tables
    @play_caller_rankings = TeamsSeason.where(season_year: 2025).play_callers.by_play_caller_rank
    @pace_rankings        = TeamsSeason.where(season_year: 2025).play_callers.by_pace_rank
    @run_heavy_rankings   = TeamsSeason.where(season_year: 2025).play_callers.by_run_heavy_rank
    @qb_passing_rankings  = TeamsSeason.where(season_year: 2025).qbs.by_grades_offense
    @receiving_rankings   = TeamsSeason.where(season_year: 2025).receiver_core_rankings
    @oline_pass_block_core_rankings = TeamsSeason.where(season_year: 2025).oline_pass_block_rankings
    @oline_run_block_core_rankings = TeamsSeason.where(season_year: 2025).oline_run_block_rankings
    @pass_rush_core_rankings = TeamsSeason.where(season_year: 2025).pass_rush_rankings
    @coverage_core_rankings = TeamsSeason.where(season_year: 2025).coverage_rankings
    @run_defense_core_rankings = TeamsSeason.where(season_year: 2025).run_defense_rankings
    @rushing_core_rankings = TeamsSeason.where(season_year: 2025).rushing_rankings
  end

  def rankings
    @qb_passing_rankings = TeamsSeason.where(season_year: 2025).qbs.by_grades_offense
    @receiving_rankings = TeamsSeason.where(season_year: 2025).receiver_core_rankings
    @oline_pass_block_core_rankings = TeamsSeason.where(season_year: 2025).oline_pass_block_rankings
    @pass_rush_core_rankings = TeamsSeason.where(season_year: 2025).pass_rush_rankings
    @coverage_core_rankings = TeamsSeason.where(season_year: 2025).coverage_rankings
    @rushing_core_rankings = TeamsSeason.where(season_year: 2025).rushing_rankings
    @oline_run_block_core_rankings = TeamsSeason.where(season_year: 2025).oline_run_block_rankings
    @run_defense_core_rankings = TeamsSeason.where(season_year: 2025).run_defense_rankings
    @play_caller_rankings = TeamsSeason.where(season_year: 2025).play_callers.by_play_caller_rank
    @pace_rankings = TeamsSeason.where(season_year: 2025).play_callers.by_pace_rank
    @run_heavy_rankings = TeamsSeason.where(season_year: 2025).play_callers.by_run_heavy_rank
  end
end
