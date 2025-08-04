class TeamsController < ApplicationController
  layout 'application'
  def rankings
    @year = params[:year]
    @teams_seasons = TeamsSeason.where(season_year: @year).includes(:team).order(:team_slug)
    # @teams_weeks      = TeamsWeek.where(season_year: @year).includes(:team)  
    @play_caller_rankings           = @teams_seasons.offensive_play_callers.by_play_caller_rank
    @offensive_play_caller_rankings = @teams_seasons.offensive_play_callers.by_play_caller_rank
    @defensive_play_caller_rankings = @teams_seasons.defensive_play_callers.by_play_caller_rank
    @pace_rankings                  = @teams_seasons.offensive_play_callers.by_pace_rank
    @run_heavy_rankings             = @teams_seasons.offensive_play_callers.by_run_heavy_rank
    @qb_passing_rankings            = @teams_seasons.qb_rankings
    @receiving_rankings             = @teams_seasons.receiver_core_rankings
    @pass_block_rankings            = @teams_seasons.oline_pass_block_rankings
    @pass_rush_rankings             = @teams_seasons.pass_rush_rankings
    @coverage_rankings              = @teams_seasons.coverage_rankings
    @rushing_rankings               = @teams_seasons.rushing_rankings
    @run_block_rankings             = @teams_seasons.oline_run_block_rankings
    @run_defense_rankings           = @teams_seasons.run_defense_rankings


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
    @play_caller_rankings = @teams_seasons.offensive_play_callers.by_play_caller_rank
    @pace_rankings        = @teams_seasons.offensive_play_callers.by_pace_rank
    @run_heavy_rankings   = @teams_seasons.offensive_play_callers.by_run_heavy_rank
    @qb_passing_rankings  = @teams_seasons.qb_rankings
    @receiving_rankings   = @teams_seasons.receiver_core_rankings
    @pass_block_rankings  = @teams_seasons.oline_pass_block_rankings
    @run_block_rankings   = @teams_seasons.oline_run_block_rankings
    @pass_rush_rankings   = @teams_seasons.pass_rush_rankings
    @coverage_rankings    = @teams_seasons.coverage_rankings
    @rushing_rankings     = @teams_seasons.rushing_rankings
    @run_defense_rankings = @teams_seasons.run_defense_rankings
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

  def substitute
    @team = Team.find_by(slug: params[:slug])
    @teams_season = TeamsSeason.find_by(team_slug: @team.slug, season_year: 2025)
    
    if @teams_season.nil?
      render json: { error: 'Team season not found' }, status: :not_found
      return
    end

    # Parse JSON body for AJAX requests
    if request.content_type == 'application/json'
      new_player_slug = params[:new_player_slug]
      position = params[:position]
    else
      new_player_slug = params[:new_player_slug]
      position = params[:position]
    end
    
    # Validate position
    valid_positions = %w[qb rb1 rb2 wr1 wr2 wr3 te c lt rt lg rg eg1 eg2 dl1 dl2 dl3 lb1 lb2 cb1 cb2 cb3 s1 s2]
    
    unless valid_positions.include?(position)
      render json: { error: 'Invalid position' }, status: :bad_request
      return
    end
    
    # Validate that the new player exists and belongs to this team
    new_player = Player.find_by(slug: new_player_slug, team_slug: @team.slug)
    unless new_player
      render json: { error: 'Player not found or does not belong to this team' }, status: :bad_request
      return
    end
    
    # Update the position with the new player
    @teams_season.update!(position => new_player_slug)
    
    render json: { success: true, message: 'Substitution successful' }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end 