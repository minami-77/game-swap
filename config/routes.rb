Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "listings/:id", to: "listings#show", as: :listing
  # Defines the root path route ("/")
  # root "posts#index"
  get "dashboard/listings/:id/offers", to: "offers#for_listing", as: :dashboard_listing_offers
  get "/dashboard", to: "dashboard#index", as: :dashboard
  resources :offers, only: [:update, :destroy, :create]
  post "/listings", to: "listings#create"
end
