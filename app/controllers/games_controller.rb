class GamesController < ApplicationController
  def week1
    @year = params[:year] || 2025
    # Get all games for the specified year week 1
    @games = Game.where(season: @year, week_slug: "1").order(:kickoff_at)
    
    # For each game, get the home and away matchups
    @games_with_predictions = @games.map do |game|
      home_matchup = Matchup.find_by(
        season: @year, 
        week_slug: "1", 
        game_slug: game.slug, 
        team_slug: game.home_slug
      )
      
      away_matchup = Matchup.find_by(
        season: @year, 
        week_slug: "1", 
        game_slug: game.slug, 
        team_slug: game.away_slug
      )
      
      {
        game: game,
        home_matchup: home_matchup,
        away_matchup: away_matchup
      }
    end
  end

  def show
    @year = params[:year] || 2025
    @game = Game.find_by(slug: params[:game_slug])
    
    if @game.nil?
      redirect_to games_week1_path(@year), alert: "Game not found"
      return
    end

    # Get the home and away matchups
    @home_matchup = Matchup.find_by(
      season: @year, 
      week_slug: "1", 
      game_slug: @game.slug, 
      team_slug: @game.home_slug
    )
    
    @away_matchup = Matchup.find_by(
      season: @year, 
      week_slug: "1", 
      game_slug: @game.slug, 
      team_slug: @game.away_slug
    )

    # Calculate predicted scores
    @home_predicted_score = calculate_predicted_score(@home_matchup)
    @away_predicted_score = calculate_predicted_score(@away_matchup)
    @total_predicted_score = @home_predicted_score + @away_predicted_score
  end

  private

  def calculate_predicted_score(matchup)
    return 0 unless matchup
    
    (matchup.passing_td_points || 0) + (matchup.rushing_td_points || 0) + (matchup.field_goal_points || 0)
  end
end 