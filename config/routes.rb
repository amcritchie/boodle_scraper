Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get 'matchups/2025/week1', to: 'matchups#week1', as: 'matchups_2025_week1'
end
