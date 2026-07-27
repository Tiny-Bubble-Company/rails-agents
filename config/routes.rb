RailsAgents::Engine.routes.draw do
  # First-run default: create workspace. Already connected → signup redirects to dashboard.
  root to: "registrations#new"

  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"
  post "signup/verify", to: "registrations#verify", as: :signup_verify

  get "signin", to: "sessions#new", as: :signin
  post "signin", to: "sessions#create"
  post "signin/verify", to: "sessions#verify", as: :signin_verify
  delete "signout", to: "sessions#destroy", as: :signout

  post "handshake", to: "handshake#create", as: :handshake
  get "connect", to: "connect#show", as: :connect

  # Deprecated compatibility: cloud-to-local pull (prefer local scaffold + `rails-agents sync`)
  post "pull", to: "pulls#create", as: :pull

  # ActiveRecord schema for Knowledge agents / database connector in dashboard
  get "schema", to: "schema#show", as: :schema

  # Production Eve runtime → Rails tool execution. The bearer token is
  # introspected against Rails Agent Cloud before any local code runs.
  post "bridge/:agent/tools/:tool", to: "tool_bridge#create", as: :tool_bridge

  get "dashboard", to: "dashboard#show", as: :dashboard
  get "dashboard/*path", to: "dashboard#proxy", as: :dashboard_proxy
end
