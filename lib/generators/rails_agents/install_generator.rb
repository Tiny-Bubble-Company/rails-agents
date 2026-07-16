# frozen_string_literal: true

require "rails/generators"

module RailsAgents
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Mount /agents dashboard + Tool Bridge, add cloud config and app/agents/"

      def create_initializer
        template "initializer.rb", "config/initializers/rails_agents.rb"
      end

      def mount_engine
        route <<~RUBY.rstrip
          # Rails Agents — Sidekiq-style UI at /agents (signup + Cloud dashboard)
          # Tip: wrap with authenticate :user / :admin in production.
          mount RailsAgents::Engine => "/agents"
        RUBY
      end

      def create_directories
        empty_directory "app/agents"
        create_file "app/agents/.keep"
      end

      def finish
        say "\n✓ Rails Agents installed.", :green
        say "  1. Visit /agents → sign up (or paste API keys)"
        say "  2. Set RAILS_AGENTS_API_KEY, APP_ID, BRIDGE_SECRET in ENV"
        say "  3. rails-agents new weather && rails-agents deploy weather"
        say "  4. Docs: https://rails.meerkatagents.com"
        say ""
        say "  Secure the UI (like Sidekiq):"
        say '    authenticate :admin do'
        say '      mount RailsAgents::Engine => "/agents"'
        say "    end"
      end
    end
  end
end
