# frozen_string_literal: true

module RailsAgents
  # Mount like Sidekiq::Web:
  #
  #   mount RailsAgents::Engine => "/agents"
  #
  # Serves the Cloud-connected dashboard at /agents and Tool Bridge at /agents/bridge.
  class Engine < ::Rails::Engine
    isolate_namespace RailsAgents
  end
end
