Rails.application.routes.draw do
  devise_for :users
  
  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'
      get 'me', to: 'sessions#me'
      get 'ping', to: 'sessions#ping'
      
      # User management
      resources :users, only: [:index, :show, :update]
      
      # Subscriptions
      resources :subscriptions, only: [:index, :show, :create] do
        post :cancel, on: :member
      end
      
      # Promotions
      resources :promotions, only: [:index, :show] do
        post :validate, on: :collection
      end
      
      # Purchase history
      resources :purchase_histories, only: [:index, :show]
    end
  end
  
  # Root path
  root "home#index"

  # User dashboard
  resource :dashboard, only: [:show] do
    get :profile
    patch :update_profile
  end

  # Subscriptions
  resource :subscription, only: [:show, :new, :create] do
    post :cancel, on: :collection
  end

  # Admin routes
  namespace :admin do
    get '/', to: 'dashboard#index', as: 'dashboard'
    resources :users
    resources :promotions do
      post :toggle_active, on: :member
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
