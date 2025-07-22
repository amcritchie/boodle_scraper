Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get 'matchups/2025/week1', to: 'matchups#week1', as: 'matchups_2025_week1'
  get 'matchups/2025/week1/roster', to: 'matchups#roster', as: 'matchups_2025_week1_roster'
  get 'matchups/2025/week1/summary', to: 'matchups#summary', as: 'matchups_2025_week1_summary'
  get 'teams/seasons', to: 'matchups#teams_seasons', as: 'teams_seasons'
  get 'rankings', to: 'matchups#rankings', as: 'rankings'
end
