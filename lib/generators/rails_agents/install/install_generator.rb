# frozen_string_literal: true

require "rails/generators/base"

module RailsAgents
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Mount the Rails Agents engine and create the initializer"

      def create_initializer
        template "initializer.rb.tt", "config/initializers/rails_agents.rb"
        template "rails_agents_autoload.rb.tt", "config/initializers/rails_agents_autoload.rb"
      end

      def mount_engine
        route "mount RailsAgents::Engine, at: \"/agents\""
      end

      def create_agents_guide
        template "AGENTS.md.tt", "AGENTS.md"
      end

      def create_workspace_library
        %w[tools skills plugins knowledge knowledge/sources].each do |folder|
          empty_directory File.join("app/agents_library", folder)
        end
        template "library_manifest.yml.tt", "app/agents_library/manifest.yml"
        template "library_README.md.tt", "app/agents_library/README.md"
      end

      def create_env_placeholders
        env_path = File.expand_path(".env", destination_root)
        placeholders = <<~ENV

          # Rails Agent Cloud platform key — NOT your OpenAI/Anthropic keys (those are BYOK in dashboard)
          # Written automatically when you connect from /agents
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
        say "  1. Start server:  bin/dev  (or bin/rails server)", :green
        say "  2. Connect:       #{url}", :green
        say "  3. Read AGENTS.md — scaffold your first database Knowledge agent:", :green
        say "     bin/rails generate rails_agents:agent my_agent --type knowledge --database", :green
        say "============================================================", :green
        say ""
      end
    end
  end
end
