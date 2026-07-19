RailsAgents::Engine.routes.draw do
  root to: "dashboard#show"

  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"
  post "signup/verify", to: "registrations#verify", as: :signup_verify

  get "signin", to: "sessions#new", as: :signin
  post "signin", to: "sessions#create"
  post "signin/verify", to: "sessions#verify", as: :signin_verify
  delete "signout", to: "sessions#destroy", as: :signout

  post "handshake", to: "handshake#create", as: :handshake
  get "connect", to: "connect#show", as: :connect

  # Local disk sync — called by the embed bridge after vibecode / before Test
  post "pull", to: "pulls#create", as: :pull

  get "dashboard", to: "dashboard#show", as: :dashboard
  get "dashboard/*path", to: "dashboard#proxy", as: :dashboard_proxy
end
