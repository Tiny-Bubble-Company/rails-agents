# frozen_string_literal: true

module RailsAgents
  class Engine < ::Rails::Engine
    isolate_namespace RailsAgents

    initializer "rails_agents.bridge_routes" do
      # Routes mounted by installer via RailsAgents::Engine, or manually.
    end
  end
end
