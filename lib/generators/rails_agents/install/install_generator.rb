# frozen_string_literal: true

require "rails/generators/base"

module RailsAgents
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Mount the Rails Agents engine and create the initializer"

      def create_initializer
        template "initializer.rb.tt", "config/initializers/rails_agents.rb"
      end

      def mount_engine
        route "mount RailsAgents::Engine, at: \"/agents\""
      end

      def create_env_placeholders
        env_path = File.expand_path(".env", destination_root)
        placeholders = <<~ENV

          # Rails Agent Cloud (https://meerkatagents.com)
          RAILS_AGENTS_API_KEY=
          RAILS_AGENTS_PROJECT_ID=
          RAILS_AGENTS_API_BASE=https://meerkatagents.com
          RAILS_AGENTS_DASHBOARD_BASE=https://meerkatagents.com
        ENV

        if File.exist?(env_path)
          unless File.read(env_path).include?("RAILS_AGENTS_API_KEY")
            append_to_file ".env", placeholders
          end
        else
          create_file ".env.rails_agents.example", placeholders.lstrip
        end
      end

      def show_readme
        readme "INSTALL" if behavior == :invoke
        say ""
        say "Next:", :green
        say "  bin/dev"
        say "  open http://localhost:3000/agents"
        say "  # or: rails-agents login"
        say ""
        say "Docs: https://meerkatagents.com/docs/getting-started"
      end
    end
  end
end
