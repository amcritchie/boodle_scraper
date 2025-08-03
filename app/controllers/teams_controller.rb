class TeamsController < ApplicationController
  layout 'application'
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
    @power_rankings   = @teams_weeks.order(power_rank_score: :desc)
    @offense_rankings = @teams_weeks.order(offense_score: :desc)
    @defense_rankings = @teams_weeks.order(defense_score: :desc)
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

  def show
    @team = Team.find_by(slug: params[:slug])
    @year = 2025 # Default to 2025 season
    
    if @team.nil?
      redirect_to teams_power_rankings_path(@year), alert: "Team not found"
      return
    end

    # Get TeamsSeason data for current team
    @teams_season = TeamsSeason.find_by(team_slug: @team.slug, season_year: @year)
    
    # Get TeamsWeek data for current team (week 1)
    @teams_week = TeamsWeek.find_by(team_slug: @team.slug, season_year: @year, week_number: 1)
    
    # Get power rankings to find adjacent teams
    @power_rankings = TeamsWeek.where(season_year: @year).includes(:team).order(power_rank_score: :desc)
    @current_team_ranking = @power_rankings.find { |ranking| ranking.team_slug == @team.slug }
    
    if @current_team_ranking
      current_index = @power_rankings.index(@current_team_ranking)
      @adjacent_teams = []
      
      # Get team above (lower rank number)
      if current_index > 0
        above_team = @power_rankings[current_index - 1]
        @adjacent_teams << { team: above_team.team, rank: current_index, direction: 'above' }
      end
      
      # Get team below (higher rank number)
      if current_index < @power_rankings.length - 1
        below_team = @power_rankings[current_index + 1]
        @adjacent_teams << { team: below_team.team, rank: current_index + 2, direction: 'below' }
      end
    end
    
    # Get all players for this team
    @all_players = Player.where(team_slug: @team.slug)
    
    # Get starters (12 offensive, 12 defensive)
    @offense_starters = @teams_season&.offense_starters || []
    @defense_starters = @teams_season&.defense_starters || []
    
    # Get bench players (all players not in starters)
    starter_slugs = (@offense_starters + @defense_starters).map(&:slug).compact
    @bench_players = @all_players.where.not(slug: starter_slugs)
    
    # Group bench players by position
    @bench_by_position = {
      'QB' => @bench_players.where(position: 'quarterback'),
      'RB' => @bench_players.where(position: 'running-back'),
      'WR' => @bench_players.where(position: 'wide-receiver'),
      'TE' => @bench_players.where(position: 'tight-end'),
      'C' => @bench_players.where(position: 'center'),
      'G' => @bench_players.where(position: 'gaurd'),
      'T' => @bench_players.where(position: 'tackle'),
      'EDGE' => @bench_players.where(position: 'edge-rusher'),
      'DL' => @bench_players.where(position: 'defensive-end'),
      'LB' => @bench_players.where(position: 'linebacker'),
      'CB' => @bench_players.where(position: 'cornerback'),
      'S' => @bench_players.where(position: 'safety'),
      'K' => @bench_players.where(position: 'place-kicker'),
      'P' => @bench_players.where(position: 'punter')
    }
  end
end 