# frozen_string_literal: true

require "rails/engine"

module RailsAgents
  class Engine < ::Rails::Engine
    isolate_namespace RailsAgents

    config.rails_agents = ActiveSupport::OrderedOptions.new

    initializer "rails_agents.assets" do |app|
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w[
          rails_agents/application.css
          rails_agents/kip-logo.png
          rails_agents/kip-waving.png
        ]
      end
    end
  end
end
