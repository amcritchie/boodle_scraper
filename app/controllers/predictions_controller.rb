class PredictionsController < ApplicationController
  def show
    @year = params[:year] || 2025
    @week = Week.find_by(season_year: @year, sequence: params[:week])
    
    if @week.nil?
      redirect_to root_path, alert: "Week not found"
      return
    end
    
    @game = Game.find_by(slug: params[:game_slug])
    
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
    
    # Set week and season for the view
    @week_number = @week.sequence
    @season = @year
    
    # Get week display name
    @week_display = case @week.sequence
                    when 1..18
                      "Week #{@week.sequence}"
                    when 19
                      "Wild Card Game"
                    when 20
                      "Divisional Round"
                    when 21
                      "Conference Championship"
                    when 22
                      "Super Bowl"
                    else
                      "Week #{@week.sequence}"
                    end
    
    # Hardcoded team colors for now
    @home_color_dark = "#1a2d24"
    @home_color_accent = "#4BAF50"
    @away_color_dark = "#2d1a24"
    @away_color_accent = "#FF7C47"
    
    # Set page title for SEO
    @page_title = "#{@away_team&.alias} vs #{@home_team&.alias} Game Summary - #{@week_display} #{@year}"
    @page_description = "Get the latest #{@away_team&.alias} vs #{@home_team&.alias} game summary for #{@week_display} of the #{@year} NFL season. Advanced game analysis and player matchups."
  end
end
