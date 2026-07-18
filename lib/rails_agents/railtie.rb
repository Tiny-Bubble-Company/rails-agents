# frozen_string_literal: true

module RailsAgents
  class Railtie < Rails::Railtie
    rake_tasks do
      load "rails_agents/tasks.rake"
    end

    generators do
      require "generators/rails_agents/install/install_generator"
      require "generators/rails_agents/agent/agent_generator"
    end
  end
end
