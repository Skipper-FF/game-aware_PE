Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users do
    resources :kids
  end
  resources :games, only: [:index, :show] do
    resources :user_reviews
  end
  get 'dashboard', to: 'pages#dashboard'
end
