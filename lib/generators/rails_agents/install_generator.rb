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
          # Rails Agents — Sidekiq-style UI at /agents
          mount RailsAgents::Engine => "/agents"
        RUBY
      end

      def create_directories
        empty_directory "app/agents"
        create_file "app/agents/.keep"
      end

      def finish
        say "\n✓ Rails Agents installed.", :green
        say "  rails-agents new weather"
        say "  rails-agents deploy weather"
        say "  → signup (first time) writes .env, opens /agents"
        say "  Docs: https://rails.meerkatagents.com"
      end
    end
  end
end
