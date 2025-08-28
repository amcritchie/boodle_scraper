Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
  get 'teams', to: 'teams#index', as: 'teams_index'
  get 'teams/:year/power-rankings', to: 'teams#power_rankings', as: 'teams_power_rankings'
  get 'teams/:year/all-rankings', to: 'teams#rankings', as: 'teams_rankings'
  get 'teams/:year/seasons', to: 'teams#teams_seasons', as: 'teams_seasons'
  get 'teams/:slug', to: 'teams#show', as: 'team_show'
  patch 'teams/:slug/substitute', to: 'teams#substitute', as: 'team_substitute'
  
  # API endpoints for teams
  post 'api/teams/:slug', to: 'teams#api_show', as: 'api_team_show'
  post 'api/teams/:year/week/:week', to: 'teams#api_week_collection', as: 'api_teams_week'
  
  get 'players', to: 'players#index', as: 'players_index'
  get 'matchups', to: 'matchups#landing', as: 'matchups_landing'
  get 'matchups/:year/week1', to: 'matchups#week1', as: 'matchups_week1'
  get 'matchups/:year/week1/roster', to: 'matchups#roster', as: 'matchups_roster'
  get 'matchups/:year/week1/summary', to: 'matchups#summary', as: 'matchups_summary'
  # get ':offense/:defense/:week/:season', to: 'matchups#matchup_summary', as: 'matchup_summary'
  get ':home/:away/:week/:season/game-summary', to: 'matchups#game_summary', as: 'game_summary'
  
  # API endpoints for matchups
  post 'api/matchups/:season/week/:week/:away_slug/:home_slug', to: 'matchups#api_show', as: 'api_matchup_show'
  post 'api/matchups/:year/week/:week', to: 'matchups#week_collection', as: 'api_matchups_week'
  
  get 'games/:year/week1', to: 'games#week1', as: 'games_week1'
  get 'games/:year/week1/betting', to: 'games#betting', as: 'games_betting'
  post 'games/:year/week1/betting', to: 'games#update_betting', as: 'update_betting'
  get 'games/:year/week1/:game_slug', to: 'games#show', as: 'game_show'
  
  # Offensive line rankings - SEO optimized
  get 'nfl-offensive-line-rankings', to: 'rankings#offensive_line', as: 'nfl_offensive_line_rankings'
  get 'rankings/offensive-line', to: 'rankings#offensive_line', as: 'offensive_line_rankings'
  get 'oline-rankings', to: 'rankings#offensive_line', as: 'oline_rankings' # Keep for backward compatibility
  
  # Predictions routes for SEO optimization
  get 'predictions/:year/week/:week/:game_slug', to: 'predictions#show', as: 'prediction_show'
  get 'nfl-week-1-predictions', to: 'predictions#week', as: 'nfl_week1_predictions'
  get 'predictions/:year/week/:week', to: 'predictions#week', as: 'predictions_week'
end
