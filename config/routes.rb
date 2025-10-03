Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  authenticated :user do
    root to: "home#index", as: :authenticated_root
  end

  unauthenticated do
    root to: "devise/sessions#new", as: :unauthenticated_root
  end

  get 'mypage', to: 'users#mypage'
  resources :posts, only: [:index, :show, :new, :create]
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