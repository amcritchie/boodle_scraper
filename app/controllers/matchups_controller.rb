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
    # Use cached values for ranking - passing_attack_score and rushing_attack_score
    @matchups = Matchup.where(season: @year, week_slug: 1)
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
