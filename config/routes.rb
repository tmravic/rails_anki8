Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "pages#home"
  get "pages/home"
  post "pages/live_update", to: "pages#live_update", as: :live_update
  post "pages/import", to: "pages#import", as: :import

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # The route is api/v1/items but the db table is products
      resources :products, path: :items
    end
  end

end
