RailsAgents::Engine.routes.draw do
  root to: "dashboard#show"

  get "signin", to: "sessions#new", as: :signin
  get "signup", to: "registrations#new", as: :signup
  delete "signout", to: "sessions#destroy", as: :signout

  post "handshake", to: "handshake#create", as: :handshake
  get "connect", to: "connect#show", as: :connect

  # Local disk sync — called by the embed bridge after vibecode / before Test
  post "pull", to: "pulls#create", as: :pull

  get "dashboard", to: "dashboard#show", as: :dashboard
  get "dashboard/*path", to: "dashboard#proxy", as: :dashboard_proxy
end
