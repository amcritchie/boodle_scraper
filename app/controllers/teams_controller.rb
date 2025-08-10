class TeamsController < ApplicationController
  layout 'application'
  
  # Skip CSRF token verification for API endpoints
  skip_before_action :verify_authenticity_token, only: [:api_show, :api_week_collection]
  
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
    
    # # Get all players for this team
    # @all_players = Player.where(team_slug: @team.slug)
    
    # # Get starters (12 offensive, 12 defensive)
    # @offense_starters = @teams_season&.offense_starters || []
    # @defense_starters = @teams_season&.defense_starters || []
    
    # Get bench players (all players not in starters)
    @bench_players = @teams_season.bench_players
    
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

  def api_show
    @team = Team.find_by(slug: params[:slug])
    
    if @team.nil?
      render json: { error: 'Team not found' }, status: :not_found
      return
    end
    
    # Get TeamsSeason data for current team (default to 2025)
    @year = params[:year] || 2025
    @teams_season = TeamsSeason.find_by(team_slug: @team.slug, season_year: @year)
    
    # Get TeamsWeek data for current team (default to week 1)
    @week = params[:week] || 1
    @teams_week = TeamsWeek.find_by(team_slug: @team.slug, season_year: @year, week_number: @week)
    
    # # Get all players for this team
    # @all_players = Player.where(team_slug: @team.slug)
    
    # # Get starters if available
    # @offense_starters = @teams_season&.offense_starters || []
    # @defense_starters = @teams_season&.defense_starters || []
    
    # # Get bench players
    # starter_slugs = (@offense_starters + @defense_starters).map(&:slug).compact
    # @bench_players = @all_players.where.not(slug: starter_slugs)
    # Get bench players (all players not in starters)
    @bench_players = @teams_week.bench_players
    
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
    
    # Build response data
    team_data = {
      team: {
        slug: @team.slug,
        name: @team.name,
        emoji: @team.emoji,
        location: @team.location,
        mascot_name: @team.mascot_name,
        conference: @team.conference,
        division: @team.division,
        active: @team.active
      },
      offense_players: {
        qb: @teams_week.qb_player,
        rb1: @teams_week.rb1_player,
        rb2: @teams_week.rb2_player,
        wr1: @teams_week.wr1_player,
        wr2: @teams_week.wr2_player,
        wr3: @teams_week.wr3_player,
        te: @teams_week.te_player,
        lt: @teams_week.left_tackle_player,
        lg: @teams_week.left_guard_player,
        c: @teams_week.center_player,
        rg: @teams_week.right_guard_player,
        rt: @teams_week.right_tackle_player,
      },
      defense_players: {
        eg1: @teams_week.edge1_player,
        eg2: @teams_week.edge2_player,
        dl1: @teams_week.dl1_player,
        dl2: @teams_week.dl2_player,
        dl3: @teams_week.dl3_player,
        lb1: @teams_week.lb1_player,
        lb2: @teams_week.lb2_player,
        cb1: @teams_week.cb1_player,
        cb2: @teams_week.cb2_player,
        cb3: @teams_week.cb3_player,
        s1: @teams_week.safety1_player,
        s2: @teams_week.safety2_player,
      },
      bench_players: @bench_by_position.transform_values { |players| players.map { |player| player_data(player) } },
      week_data: @teams_week ? {
        week_number: @teams_week.week_number,
        power_rank_score: @teams_week.power_rank_score,
        offense_score: @teams_week.offense_score,
        defense_score: @teams_week.defense_score
      } : nil,
    }
    
    render json: team_data
  end
  
  def api_week_collection
    @year = params[:year] || 2025
    @week = params[:week] || 1
    
    # Get all teams for the specified week
    @teams_weeks = TeamsWeek.where(season_year: @year, week_number: @week).includes(:team).order(power_rank_score: :desc)
    
    # Get teams seasons data for additional rankings
    @teams_seasons = TeamsSeason.where(season_year: @year).includes(:team).order(:team_slug)
    
    # Build response data
    teams_data = @teams_weeks.map do |team_week|
      team = team_week.team
      team_season = @teams_seasons.find { |ts| ts.team_slug == team.slug }
      
      {
        team: {
          slug: team.slug,
          name: team.name,
          emoji: team.emoji,
          location: team.location,
          mascot_name: team.mascot_name,
          conference: team.conference,
          division: team.division
        },
        week_stats: {
          week_number: team_week.week_number,
          power_rank_score: team_week.power_rank_score,
          offense_score: team_week.offense_score,
          defense_score: team_week.defense_score
        }
      }
    end
    
    response_data = {
      season_year: @year,
      week_number: @week,
      total_teams: teams_data.count,
      teams: teams_data
    }
    
    render json: response_data
  end
  
  private
  
  def player_data(player)
    {
      slug: player.slug,
      first_name: player.first_name,
      last_name: player.last_name,
      position: player.position,
      position_starter: player.position_starter,
      grades_pass: player.grades_pass,
      grades_rush: player.grades_run,
      grades_pass_route: player.grades_pass_route,
      grades_pass_block: player.grades_pass_block,
      grades_run_block: player.grades_run_block,
      grades_pass_rush: player.grades_pass_rush,
      grades_run_defense: player.grades_rush_defense,
      grades_coverage: player.grades_coverage
    }
  end
end 