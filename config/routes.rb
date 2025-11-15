Rails.application.routes.draw do
  get "pages/terms"
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }

  authenticated :user do
    root to: "home#index", as: :authenticated_root
  end

  get 'search', to: 'searches#search', as: 'search'

  get 'terms', to: 'pages#terms'
  get 'privacy_policy', to: 'pages#privacy_policy'

  unauthenticated do
    root to: redirect('/users/sign_in')
  end

  get 'mypage', to: 'users#mypage'

  get 'my_posts', to: 'posts#my_posts', as: :my_posts

  namespace :mypage do
    resources :posts, only: [:index, :destroy]
  end

  resources :posts, only: [:index, :show, :new, :create, :destroy] do
    resources :star_ratings, only: [:create]
    resources :comments, only: [:create]
    resource :bookmark, only: [:create, :destroy]
  end
  post 'posts/:id/evaluate/:kind', to: 'evaluations#create', as: :evaluate_post

  resources :bookmarks, only: [:index]
  resources :users, only: [:show, :update] do
    collection do
      get :mypage
      patch :reset_mypage_background
      patch :reset_window_background
    end
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # PWA関連
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end