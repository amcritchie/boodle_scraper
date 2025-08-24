class MatchupsController < ApplicationController
  # Skip CSRF token verification for API endpoints
  skip_before_action :verify_authenticity_token, only: [:api_show, :api_week_collection]
  
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
    @passing_sort = params[:passing_sort] || 'passing_attack_rank'
    @rushing_sort = params[:rushing_sort] || 'rushing_attack_rank'
    
    # Use cached values for ranking - passing_attack_score and rushing_attack_score
    @matchups = Matchup.where(season: @year, week_slug: 1)
    
    # Apply sorting based on the passing_sort parameter for passing table
    case @passing_sort
    when 'passing_yards'
      @passing_matchups = @matchups.order(prediction_passing_yards: :desc)
    when 'pocket_time'
      @passing_matchups = @matchups.order(prediction_seconds_until_pressure: :desc)
    when 'passing_attempts'
      @passing_matchups = @matchups.order(prediction_passing_attempts: :desc)
    when 'yards_per_attempt'
      @passing_matchups = @matchups.order(prediction_yards_per_attempt: :desc)
    else
      @passing_matchups = @matchups.order(passing_attack_rank: :asc)
    end
    
    # Apply sorting based on the rushing_sort parameter for rushing table
    case @rushing_sort
    when 'rushing_yards'
      @rushing_matchups = @matchups.order(prediction_rushing_yards: :desc)
    when 'carry_attempts'
      @rushing_matchups = @matchups.order(prediction_carry_attempts: :desc)
    when 'yards_per_carry'
      @rushing_matchups = @matchups.order(prediction_yards_per_carry: :desc)
    else
      @rushing_matchups = @matchups.order(:rushing_attack_rank)
    end

    # Prepare background colors for each matchup based on their rank
    @passing_matchups_with_colors = @passing_matchups.map.with_index do |matchup, index|
      {
        matchup: matchup,
        background_color: get_rank_background_color(index + 1)
      }
    end
    
    # Prepare rushing table data with colors (using separate sorting and color logic)
    @rushing_matchups_with_colors = @rushing_matchups.map.with_index do |matchup, index|
      {
        matchup: matchup,
        background_color: get_rushing_rank_background_color(index + 1)
      }
    end
    
    # Prepare field goal table data with colors
    @field_goal_matchups_with_colors = @matchups.order(:field_goal_points).reverse.map.with_index do |matchup, index|
      {
        matchup: matchup,
        background_color: get_rank_background_color(index + 1)
      }
    end
  end
  
  def api_show
    @season = params[:season]
    @week = params[:week]
    @home_slug = params[:home_slug]
    @away_slug = params[:away_slug]
    
    # Find matchup by season, week, and team slugs
    @matchup = Matchup.find_by(
      season: @season,
      week_slug: @week,
      team_slug: @home_slug,
      team_defense_slug: @away_slug
    )
    
    # If not found with home team first, try the reverse
    if @matchup.nil?
      @matchup = Matchup.find_by(
        season: @season,
        week_slug: @week,
        team_slug: @away_slug,
        team_defense_slug: @home_slug
      )
    end
    
    if @matchup.nil?
      render json: { 
        error: 'Matchup not found',
        search_params: {
          season: @season,
          week: @week,
          home_slug: @home_slug,
          away_slug: @away_slug
        }
      }, status: :not_found
      return
    end
    
    # Build response data
    matchup_data = {
      id: @matchup.id,
      season: @matchup.season,
      week_slug: @matchup.week_slug,
      game_slug: @matchup.game_slug,
      home: @matchup.home,
      offense_team: {
        slug: @matchup.team_slug,
        name: @matchup.team&.name,
        emoji: @matchup.team&.emoji
      },
      defense_team: {
        slug: @matchup.team_defense_slug,
        name: @matchup.team_defense&.name,
        emoji: @matchup.team_defense&.emoji
      },
      scores: {
        passing_offense_score: @matchup.passing_offense_score,
        rushing_offense_score: @matchup.rushing_offense_score,
        passing_defense_score: @matchup.passing_defense_score,
        rushing_defense_score: @matchup.rushing_defense_score,
        passing_attack_score: @matchup.passing_attack_score,
        rushing_attack_score: @matchup.rushing_attack_score,
        sack_score: @matchup.sack_score,
        coverage_score: @matchup.coverage_score
      },
      rankings: {
        offensive_play_caller_rank: @matchup.offensive_play_caller_rank,
        pace_of_play_rank: @matchup.pace_of_play_rank,
        run_heavy_rank: @matchup.run_heavy_rank,
        qb_passing_rank: @matchup.qb_passing_rank,
        receiver_core_rank: @matchup.receiver_core_rank,
        pass_block_rank: @matchup.pass_block_rank
      },
      roster: {
        qb: player_data(@matchup.qb),
        rb1: player_data(@matchup.rb1),
        rb2: player_data(@matchup.rb2),
        wr1: player_data(@matchup.wr1),
        wr2: player_data(@matchup.wr2),
        wr3: player_data(@matchup.wr3),
        te: player_data(@matchup.te),
        c: player_data(@matchup.c),
        lt: player_data(@matchup.lt),
        rt: player_data(@matchup.rt),
        lg: player_data(@matchup.lg),
        rg: player_data(@matchup.rg),
        eg1: player_data(@matchup.eg1),
        eg2: player_data(@matchup.eg2),
        dl1: player_data(@matchup.dl1),
        dl2: player_data(@matchup.dl2),
        dl3: player_data(@matchup.dl3),
        lb1: player_data(@matchup.lb1),
        lb2: player_data(@matchup.lb2),
        cb1: player_data(@matchup.cb1),
        cb2: player_data(@matchup.cb2),
        cb3: player_data(@matchup.cb3),
        s1: player_data(@matchup.s1),
        s2: player_data(@matchup.s2)
      },
      predictions: {
        # passing_touchdowns: @matchup.passing_touchdowns,
        # rushing_touchdowns: @matchup.rushing_touchdowns,
        # field_goals: @matchup.field_goals
      }
    }
    
    render json: matchup_data
  end
  
  def api_week_collection
    @year = params[:year] || 2025
    @week = params[:week] || 1
    
    # Get all matchups for the specified week
    @matchups = Matchup.where(season: @year, week_slug: @week).order(passing_attack_score: :desc)
    
    # Build response data
    matchups_data = @matchups.map do |matchup|
      {
        id: matchup.id,
        season: matchup.season,
        week_slug: matchup.week_slug,
        game_slug: matchup.game_slug,
        home: matchup.home,
        team: {
          slug: matchup.team_slug,
          name: matchup.team&.name,
          emoji: matchup.team&.emoji
        },
        team_defense: {
          slug: matchup.team_defense_slug,
          name: matchup.team_defense&.name,
          emoji: matchup.team_defense&.emoji
        },
        scores: {
          passing_offense_score: matchup.passing_offense_score,
          rushing_offense_score: matchup.rushing_offense_score,
          passing_defense_score: matchup.passing_defense_score,
          rushing_defense_score: matchup.rushing_defense_score,
          passing_attack_score: matchup.passing_attack_score,
          rushing_attack_score: matchup.rushing_attack_score,
          sack_score: matchup.sack_score,
          coverage_score: matchup.coverage_score
        },
        rankings: {
          offensive_play_caller_rank: matchup.offensive_play_caller_rank,
          pace_of_play_rank: matchup.pace_of_play_rank,
          run_heavy_rank: matchup.run_heavy_rank,
          qb_passing_rank: matchup.qb_passing_rank,
          receiver_core_rank: matchup.receiver_core_rank,
          pass_block_rank: matchup.pass_block_rank
        },
        predictions: {
          # passing_touchdowns: matchup.passing_touchdowns,
          # rushing_touchdowns: matchup.rushing_touchdowns,
          # field_goals: matchup.field_goals
        }
      }
    end
    
    response_data = {
      season_year: @year,
      week_number: @week,
      total_matchups: matchups_data.count,
      matchups: matchups_data
    }
    
    render json: response_data
  end
  
  private
  
  def get_rank_background_color(rank)
    case rank
    when 1..2
      'bg-green-600 hover:bg-green-700'
    when 3..5
      'bg-green-500 hover:bg-green-600'
    when 6..14
      'bg-green-400 hover:bg-green-500'
    when 26..32
      'bg-red-400 hover:bg-red-500'
    else
      'hover:bg-gray-700'
    end
  end
  
  def get_rushing_rank_background_color(rank)
    case rank
    when 1..2
      'bg-green-600 hover:bg-green-700'
    when 3..7
      'bg-green-500 hover:bg-green-600'
    when 21..32
      'bg-red-400 hover:bg-red-500'
    else
      'hover:bg-gray-700'
    end
  end
  
  def player_data(player_slug)
    return nil if player_slug.blank?
    
    player = Player.find_by(slug: player_slug)
    return nil unless player
    
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
