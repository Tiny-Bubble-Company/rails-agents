# frozen_string_literal: true

require "rails/engine"

module RailsAgents
  class Engine < ::Rails::Engine
    isolate_namespace RailsAgents

    config.rails_agents = ActiveSupport::OrderedOptions.new

    initializer "rails_agents.assets" do |app|
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w[rails_agents/application.css]
      end
    end
  end
end
