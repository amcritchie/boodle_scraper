class PredictionsController < ApplicationController

  def week
    @year = params[:year] || 2025
    @week_number = params[:week] || 1
    @week = Week.find_by(season_year: @year, sequence: @week_number)
    puts "Week #{@week_number} for #{@year} season"
    if @week.nil?
      redirect_to root_path, alert: "Week #{@week_number} not found for #{@year} season"
      return
    end
    puts "Week #{@week_number} for #{@year} season"
    
    # Get all games for the specified week with their matchups
    @games = @week.games.includes(:home_team, :away_team, :venue, :matchups)
    
    # First, collect all unique kickoff times and group by day
    @games_by_day_time = {}
    
    @games.each do |game|
      next unless game.kickoff_at.present?
      
      # Get day and formatted time from kickoff_at
      day = game.kickoff_at.strftime('%A') # Monday, Tuesday, etc.
      time = game.kickoff_at.strftime('%I:%M %p') # 6:20 PM
      day_time_key = "#{day} • #{time}"
      
      # Initialize the day if it doesn't exist
      @games_by_day_time[day] ||= {}
      @games_by_day_time[day][time] ||= []
      
      # Get matchup data for this game
      home_matchup = game.matchups.find_by(team_slug: game.home_slug)
      away_matchup = game.matchups.find_by(team_slug: game.away_slug)
      
      game_data = {
        game: game,
        home_matchup: home_matchup,
        away_matchup: away_matchup,
        home_team: game.home_team,
        away_team: game.away_team,
        venue: game.venue,
        kickoff_at: game.kickoff_at
      }
      
      @games_by_day_time[day][time] << game_data
    end
    
    # Sort games within each time slot by predicted total score (highest first)
    @games_by_day_time.each do |day, times|
      times.each do |time, games|
        games.sort_by! { |g| -(g[:home_matchup]&.predicted_score.to_f + g[:away_matchup]&.predicted_score.to_f) }
      end
    end
    
    # Sort days in logical order (Thursday, Sunday, Monday)
    @day_order = ['Thursday', 'Friday', 'Saturday', 'Sunday', 'Monday']
    @games_by_day_time = @games_by_day_time.sort_by { |day, _| @day_order.index(day) || 999 }.to_h
    
    # Set page title and description for SEO
    @page_title = "NFL Week #{@week_number} Predictions #{@year} - Game Picks & Score Predictions"
    @page_description = "Get expert NFL Week #{@week_number} predictions for the #{@year} season. View game picks, predicted scores, and analysis for every matchup. Expert analysis and betting insights."
  end

  def show
    @year = params[:year] || 2025
    @week = Week.find_by(season_year: @year, sequence: params[:week])
    
    if @week.nil?
      redirect_to root_path, alert: "Week not found"
      return
    end
    
    @game = @week.games.find_by(slug: params[:game_slug])
    
    if @game.nil?
      redirect_to games_week1_path(@year), alert: "Game not found"
      return
    end
    
    # Get the home and away matchups
    @home_matchup = @game.matchups.find_by(team_slug: @game.home_slug)
    @away_matchup = @game.matchups.find_by(team_slug: @game.away_slug)
    
    # Get teams
    @home_team = Team.find_by(slug: @game.home_slug)
    @away_team = Team.find_by(slug: @game.away_slug)

    # Get venue
    @venue = @game.venue

    # Get gradient styling from Game model
    @hero_gradient_style = @game.hero_gradient_style
    @text_gradient_style = @game.text_gradient_style

    # Get week display name from Week model
    @week_display = @week.display_name
    
    @home_text = @home_team&.color_accent_text
    @away_text = @away_team&.color_accent_text
    
    # Set page title for SEO
    @page_title = "#{@away_team&.alias} vs #{@home_team&.alias} Game Summary - #{@week_display} #{@year}"
    @page_description = "Get the latest #{@away_team&.alias} vs #{@home_team&.alias} game summary for #{@week_display} of the #{@year} NFL season. Advanced game analysis and player matchups."
  end
end
