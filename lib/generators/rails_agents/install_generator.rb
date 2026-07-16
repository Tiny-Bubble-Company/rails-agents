# frozen_string_literal: true

require "rails/generators"

module RailsAgents
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Add Rails Agents cloud config, bridge route, and agent directories"

      def create_initializer
        template "initializer.rb", "config/initializers/rails_agents.rb"
      end

      def mount_engine
        route 'mount RailsAgents::Engine => "/rails_agents"'
      end

      def create_directories
        empty_directory "app/agents"
        create_file "app/agents/.keep"
      end

      def finish
        say "\n✓ Rails Agents (cloud) installed.", :green
        say "  1. Sign up and create a sandbox API key"
        say "  2. Set RAILS_AGENTS_API_KEY and RAILS_AGENTS_BRIDGE_SECRET"
        say "  3. Create an agent under app/agents/<name>/"
        say "  4. Docs: https://tiny-bubble-company.github.io/rails-agents/"
      end
    end
  end
end
