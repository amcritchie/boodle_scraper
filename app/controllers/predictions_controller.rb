class PredictionsController < ApplicationController




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
