# frozen_string_literal: true

RailsAgents::Engine.routes.draw do
  post "bridge", to: "cloud/bridge#create"
end
