Rails.application.routes.draw do
  get "posts/index"
  root to: "home#index"
  get "home/index"
  get 'mypage', to: 'users#mypage'
  resources :posts, only: [:index]

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # PWA関連
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # ユーザー情報の表示・編集を追加したい場合は以下を使う
  # resources :users, only: [:show, :edit, :update]
end
