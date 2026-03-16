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
  get  'api/teams/search',           to: 'teams#api_search',          as: 'api_teams_search'
  post 'api/teams/:slug',            to: 'teams#api_show',            as: 'api_team_show'
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
  
  # Memes (HTML)
  resources :memes

  # Memes (API)
  get    'api/memes',      to: 'memes#api_index',   as: 'api_memes'
  post   'api/memes',      to: 'memes#api_create',  as: 'api_memes_create'
  get    'api/memes/:id',  to: 'memes#api_show',    as: 'api_meme_show'
  patch  'api/memes/:id',  to: 'memes#api_update',  as: 'api_meme_update'
  delete 'api/memes/:id',  to: 'memes#api_destroy', as: 'api_meme_destroy'

  # Contents (HTML)
  resources :contents

  # Contents (API)
  get    'api/contents',                    to: 'contents#api_index',      as: 'api_contents'
  post   'api/contents',                    to: 'contents#api_create',     as: 'api_contents_create'
  get    'api/contents/:id',                to: 'contents#api_show',       as: 'api_content_show'
  patch  'api/contents/:id',                to: 'contents#api_update',     as: 'api_content_update'
  patch  'api/contents/:id/transition',     to: 'contents#api_transition', as: 'api_content_transition'
  patch  'api/contents/:id/rank',           to: 'contents#api_rank',       as: 'api_content_rank'
  delete 'api/contents/:id',                to: 'contents#api_destroy',    as: 'api_content_destroy'

  # News (HTML)
  resources :news, except: [] do
    collection do
      get :archived
    end
    member do
      patch :select_image
    end
  end

  # News (API)
  get    'api/news',                   to: 'news#api_index',           as: 'api_news'
  post   'api/news',                   to: 'news#api_create',          as: 'api_news_create'
  post   'api/news/organize_ranks',    to: 'news#api_organize_ranks',  as: 'api_organize_ranks'
  get    'api/news/posting_schedule',  to: 'news#api_posting_schedule', as: 'api_posting_schedule'
  get    'api/news/:id',               to: 'news#api_show',            as: 'api_news_show'
  patch  'api/news/:id',               to: 'news#api_update',          as: 'api_news_update'
  delete 'api/news/:id',               to: 'news#api_destroy',         as: 'api_news_destroy'
  patch  'api/news/:id/transition',    to: 'news#api_transition',      as: 'api_news_transition'
  patch  'api/news/:id/select_image',  to: 'news#api_select_image',    as: 'api_news_select_image'
  patch  'api/news/:id/rank',          to: 'news#api_rank',            as: 'api_rank_news'

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

  # ─── Agent Dashboard (HTML) ──────────────────────────────────────
  get  'agents',                  to: 'agents_dashboard#dashboard',      as: 'agents_dashboard'
  get  'agents/list',             to: 'agents_dashboard#agents_index',   as: 'agents_dashboard_list'
  get  'agents/new',              to: 'agents_dashboard#agents_new',     as: 'agents_dashboard_new'
  post 'agents/create',           to: 'agents_dashboard#agents_create',  as: 'agents_dashboard_create'
  get  'agents/tasks/all',        to: 'agents_dashboard#tasks_index',    as: 'agents_dashboard_tasks'
  get  'agents/tasks/new',        to: 'agents_dashboard#tasks_new',      as: 'agents_dashboard_tasks_new'
  post 'agents/tasks/create',     to: 'agents_dashboard#tasks_create',   as: 'agents_dashboard_tasks_create'
  get  'agents/tasks/:id',        to: 'agents_dashboard#tasks_show',     as: 'agents_dashboard_task'
  get  'agents/tasks/:id/edit',   to: 'agents_dashboard#tasks_edit',     as: 'agents_dashboard_task_edit'
  patch 'agents/tasks/:id',       to: 'agents_dashboard#tasks_update',   as: 'agents_dashboard_task_update'
  delete 'agents/tasks/:id',      to: 'agents_dashboard#tasks_destroy',  as: 'agents_dashboard_task_destroy'
  get  'agents/activity/feed',    to: 'agents_dashboard#activity_index', as: 'agents_dashboard_activity'
  get  'agents/skills/all',       to: 'agents_dashboard#skills_index',   as: 'agents_dashboard_skills'
  get  'agents/usage/overview',   to: 'agents_dashboard#usage_index',    as: 'agents_dashboard_usage'
  get  'agents/:slug/edit',       to: 'agents_dashboard#agents_edit',    as: 'agents_dashboard_edit'
  patch 'agents/:slug',           to: 'agents_dashboard#agents_update',  as: 'agents_dashboard_update'
  delete 'agents/:slug',          to: 'agents_dashboard#agents_destroy', as: 'agents_dashboard_destroy'
  get  'agents/:slug',            to: 'agents_dashboard#agents_show',    as: 'agents_dashboard_show'

  # ─── Agent Dashboard (API) ──────────────────────────────────────
  get    'api/agents/dashboard',          to: 'agents_dashboard#api_dashboard',              as: 'api_agents_dashboard'
  get    'api/agents/tasks',              to: 'agents_dashboard#api_tasks_index',             as: 'api_agent_tasks'
  post   'api/agents/tasks',             to: 'agents_dashboard#api_tasks_create',            as: 'api_agent_tasks_create'
  get    'api/agents/tasks/:id',          to: 'agents_dashboard#api_tasks_show',              as: 'api_agent_task'
  patch  'api/agents/tasks/:id',          to: 'agents_dashboard#api_tasks_update',             as: 'api_agent_task_update'
  delete 'api/agents/tasks/:id',          to: 'agents_dashboard#api_tasks_destroy',            as: 'api_agent_task_destroy'
  patch  'api/agents/tasks/:id/assign',   to: 'agents_dashboard#api_tasks_assign',             as: 'api_agent_task_assign'
  patch  'api/agents/tasks/:id/transition', to: 'agents_dashboard#api_tasks_transition',       as: 'api_agent_task_transition'
  get    'api/agents/skills',             to: 'agents_dashboard#api_skills_index',             as: 'api_agent_skills'
  post   'api/agents/skills',            to: 'agents_dashboard#api_skills_create',            as: 'api_agent_skills_create'
  get    'api/agents/skills/:slug',       to: 'agents_dashboard#api_skills_show',              as: 'api_agent_skill'
  delete 'api/agents/skills/:slug',       to: 'agents_dashboard#api_skills_destroy',           as: 'api_agent_skill_destroy'
  post   'api/agents/skill_assignments',  to: 'agents_dashboard#api_skill_assignments_create', as: 'api_agent_skill_assignments_create'
  delete 'api/agents/skill_assignments/:id', to: 'agents_dashboard#api_skill_assignments_destroy', as: 'api_agent_skill_assignment_destroy'
  post   'api/agents/push',               to: 'agents_dashboard#api_push',                    as: 'api_agents_push'
  get    'api/agents/activities',         to: 'agents_dashboard#api_activities_index',         as: 'api_agent_activities'
  post   'api/agents/activities',         to: 'agents_dashboard#api_activities_create',        as: 'api_agent_activities_create'
  get    'api/agents/usages',             to: 'agents_dashboard#api_usages_index',             as: 'api_agent_usages'
  post   'api/agents/usages',            to: 'agents_dashboard#api_usages_create',            as: 'api_agent_usages_create'
  get    'api/agents',                    to: 'agents_dashboard#api_agents_index',             as: 'api_agents'
  post   'api/agents',                   to: 'agents_dashboard#api_agents_create',            as: 'api_agents_create'
  get    'api/agents/:slug',              to: 'agents_dashboard#api_agents_show',              as: 'api_agent'
  patch  'api/agents/:slug',              to: 'agents_dashboard#api_agents_update',             as: 'api_agent_update'
  patch  'api/agents/:slug/model',        to: 'agents_dashboard#api_agent_set_model',            as: 'api_agent_set_model'
  delete 'api/agents/:slug',              to: 'agents_dashboard#api_agents_destroy',            as: 'api_agent_destroy'
end
