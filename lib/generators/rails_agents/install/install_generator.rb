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

          # Rails Agent Cloud — get these at https://cloud.rails-agent.com/dashboard/keys
          # (also written automatically when you connect from /agents)
          RAILS_AGENTS_API_KEY=
          RAILS_AGENTS_PROJECT_ID=
        ENV

        if File.exist?(env_path)
          unless File.read(env_path).include?("RAILS_AGENTS_API_KEY")
            append_to_file ".env", placeholders
          end
        else
          create_file ".env.rails_agents.example", placeholders.lstrip
        end
      end

      def show_next_steps
        return unless behavior == :invoke

        port = ENV.fetch("PORT", "3000")
        url = "http://localhost:#{port}/agents"

        say ""
        say "============================================================", :green
        say "  Rails Agents installed", :green
        say "============================================================", :green
        say ""
        say "  Start your Rails server, then open the Agents UI:", :green
        say "    bin/dev     (or: bin/rails server)", :green
        say "    #{url}", :green
        say ""
        say "  Guide: https://rails-agent.com/docs/getting-started", :green
        say "============================================================", :green
        say ""
      end
    end
  end
end
