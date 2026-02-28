Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
  resources :people, except: [:show]
  resources :posts, except: [:show]
  resources :articles, except: [:show] do
    member do
      patch :feedback
      patch :select_image
    end
  end
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
  
  # API endpoints for people
  get    'api/people',      to: 'people#api_index',   as: 'api_people'
  post   'api/people',      to: 'people#api_create',  as: 'api_people_create'
  get    'api/people/:id',  to: 'people#api_show',    as: 'api_person_show'
  patch  'api/people/:id',  to: 'people#api_update',  as: 'api_person_update'
  delete 'api/people/:id',  to: 'people#api_destroy', as: 'api_person_destroy'

  # API endpoints for posts
  get    'api/posts',      to: 'posts#api_index',   as: 'api_posts'
  post   'api/posts',      to: 'posts#api_create',  as: 'api_posts_create'
  get    'api/posts/:id',  to: 'posts#api_show',    as: 'api_post_show'
  patch  'api/posts/:id',  to: 'posts#api_update',  as: 'api_post_update'
  delete 'api/posts/:id',  to: 'posts#api_destroy', as: 'api_post_destroy'

  # API endpoints for articles
  get  'api/articles',              to: 'articles#api_index',    as: 'api_articles'
  post 'api/articles',              to: 'articles#api_create',   as: 'api_articles_create'
  get  'api/articles/docs',         to: 'articles#api_docs',     as: 'api_articles_docs'
  post 'api/articles/ingest',       to: 'articles#api_ingest',   as: 'api_articles_ingest'
  get  'api/articles/:id',          to: 'articles#api_show',     as: 'api_article_show'
  patch 'api/articles/:id',         to: 'articles#api_update',   as: 'api_article_update'
  patch 'api/articles/:id/feedback', to: 'articles#api_feedback', as: 'api_article_feedback'
  patch 'api/articles/:id/select_image', to: 'articles#api_select_image', as: 'api_article_select_image'
  delete 'api/articles/:id',        to: 'articles#api_destroy',  as: 'api_article_destroy'

  # API endpoints for matchups
  post 'api/matchups/:season/week/:week/:away_slug/:home_slug', to: 'matchups#api_show', as: 'api_matchup_show'
  post 'api/matchups/:year/week/:week', to: 'matchups#week_collection', as: 'api_matchups_week'
  
  get 'games/:year/week1', to: 'games#week1', as: 'games_week1'
  get 'games/:year/week1/betting', to: 'games#betting', as: 'games_betting'
  post 'games/:year/week1/betting', to: 'games#update_betting', as: 'update_betting'
  get 'games/:year/week1/:game_slug', to: 'games#show', as: 'game_show'
  get 'games', to: 'games#all_games', as: 'all_games'
  
  # Offensive line rankings - SEO optimized
  get 'nfl-offensive-line-rankings', to: 'rankings#offensive_line', as: 'nfl_offensive_line_rankings'
  get 'rankings/offensive-line', to: 'rankings#offensive_line', as: 'offensive_line_rankings'
  get 'oline-rankings', to: 'rankings#offensive_line', as: 'oline_rankings' # Keep for backward compatibility
  
  # Quarterback rankings - SEO optimized
  get 'nfl-quarterback-rankings', to: 'rankings#quarterback', as: 'nfl_quarterback_rankings'
  get 'rankings/quarterback', to: 'rankings#quarterback', as: 'quarterback_rankings'
  get 'qb-rankings', to: 'rankings#quarterback', as: 'qb_rankings' # Keep for backward compatibility
  
  # Predictions routes for SEO optimization
  get 'predictions/:year/week/:week/:game_slug', to: 'predictions#show', as: 'prediction_show'
  get 'nfl-week-1-predictions', to: 'predictions#week', as: 'nfl_week1_predictions'
  get 'predictions/:year/week/:week', to: 'predictions#week', as: 'predictions_week'
end
