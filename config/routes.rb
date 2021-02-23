Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users do
    resources :kids
    resources :user_reviews, only: [:index, :new, :edit, :update, :destroy]
  end
  resources :games, only: [:index, :show]
end
