Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  authenticated :user do
    root to: "home#index", as: :authenticated_root
  end

  get 'search', to: 'searches#search', as: 'search'

  unauthenticated do
    root to: redirect('/users/sign_in')
  end

  get 'mypage', to: 'users#mypage'
  resources :posts, only: [:index, :show, :new, :create] do
    resources :comments, only: [:create]
    resource :bookmark, only: [:create, :destroy]
  end
  resources :bookmarks, only: [:index]
  resources :users, only: [:show, :update] do
    collection do
      get :mypage
      patch :reset_mypage_background
      patch :reset_window_background
    end
  end

  # PWA関連
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end