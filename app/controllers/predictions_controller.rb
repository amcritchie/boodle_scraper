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
    
    # Calculate predicted scores
    @home_predicted_score = @home_matchup&.predicted_score || 0
    @away_predicted_score = @away_matchup&.predicted_score || 0
    @total_predicted_score = @home_predicted_score + @away_predicted_score
    
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
    
    # Set page title for SEO
    @page_title = "#{@away_team&.alias} vs #{@home_team&.alias} Prediction - #{@week_display} #{@year}"
    @page_description = "Get the latest #{@away_team&.alias} vs #{@home_team&.alias} prediction for #{@week_display} of the #{@year} NFL season. Expert analysis, predicted scores, and betting insights."
  end
end
