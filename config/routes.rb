Rails.application.routes.draw do
  resource :session
  root "dashboard#index"
  resources :screenshots, only: %i[index show]

  namespace :admin do
    resources :newspapers do
      post :capture, on: :member
      post :capture_selected, on: :collection
    end
    resources :users, only: %i[index new create edit update]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
