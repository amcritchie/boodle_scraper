Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get 'teams/:year/power-rankings', to: 'teams#power_rankings', as: 'teams_power_rankings'
  get 'teams/:year/all-rankings', to: 'teams#rankings', as: 'teams_rankings'
  get 'teams/:year/seasons', to: 'teams#teams_seasons', as: 'teams_seasons'
  get 'teams/:slug', to: 'teams#show', as: 'team_show'
  get 'players', to: 'players#index', as: 'players_index'
  get 'matchups/:year/week1', to: 'matchups#week1', as: 'matchups_week1'
  get 'matchups/:year/week1/roster', to: 'matchups#roster', as: 'matchups_roster'
  get 'matchups/:year/week1/summary', to: 'matchups#summary', as: 'matchups_summary'
  get 'games/:year/week1', to: 'games#week1', as: 'games_week1'
  get 'games/:year/week1/:game_slug', to: 'games#show', as: 'game_show'
end
