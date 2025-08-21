class GamesController < ApplicationController
  def week1
    @year = params[:year] || 2025
    @week = Week.find_by(season_year: @year, sequence: 1)
    
    if @week.nil?
      redirect_to root_path, alert: "Week not found"
      return
    end
    
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
        away_matchup: away_matchup,
        matchups: [home_matchup, away_matchup].compact
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
    @home_matchup = @game.matchups.find_by(team_slug: @game.home_slug)
    @away_matchup = @game.matchups.find_by(team_slug: @game.away_slug)

    # Calculate predicted scores
    @total_predicted_score = @home_matchup.predicted_score + @away_matchup.predicted_score
  end

  def betting
    @year = params[:year] || 2025
    @week = Week.find_by(season_year: @year, sequence: 1)
    
    if @week.nil?
      redirect_to games_week1_path(@year), alert: "Week not found"
      return
    end
    
    # Get all games for the specified year week 1
    @games = Game.where(season: @year, week_slug: "1").order(:kickoff_at)
  end

  def update_betting
    @year = params[:year] || 2025
    @week = Week.find_by(season_year: @year, sequence: 1)
    
    if @week.nil?
      redirect_to games_week1_path(@year), alert: "Week not found"
      return
    end

    # Process betting data for each game
    params[:games].each do |game_slug, betting_data|
      game = Game.find_by(slug: game_slug)
      next unless game
      
      favorite = betting_data[:favorite]
      favorite_spread = betting_data[:favorite_spread].to_f
      over_under = betting_data[:over_under].to_f
      
      # Calculate implied team totals
      implied_totals = game.set_implied_totals(favorite, favorite_spread, over_under)
      
      # Update game with betting data
      game.update(
        favorite: favorite,
        favorite_spread: favorite_spread,
        over_under: over_under
      )
    end
    
    redirect_to games_betting_path(@year), notice: "Betting data updated successfully!"
  end

  private
end 