# frozen_string_literal: true

RailsAgents::Engine.routes.draw do
  root to: "dashboard#index"

  post "signup", to: "dashboard#create_account", as: :signup
  post "connect", to: "dashboard#connect", as: :connect
  post "disconnect", to: "dashboard#disconnect", as: :disconnect
  get "agents/:id", to: "dashboard#show", as: :agent

  # Tool Bridge (HMAC) — default path when mounted at /agents → /agents/bridge
  post "bridge", to: "cloud/bridge#create"
end
