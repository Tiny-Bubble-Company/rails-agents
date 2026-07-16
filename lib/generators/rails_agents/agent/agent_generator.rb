# frozen_string_literal: true

require "rails/generators"

module RailsAgents
  module Generators
    class AgentGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      desc "Create Eve-shaped agent directory under app/agents/NAME"

      def create_agent_directory
        empty_directory "app/agents/#{file_name}"
        empty_directory "app/agents/#{file_name}/schedules"
        empty_directory "app/agents/#{file_name}/tools"
        empty_directory "app/agents/#{file_name}/skills"
        template "instructions.md.tt", "app/agents/#{file_name}/instructions.md"
        template "agent.json.tt", "app/agents/#{file_name}/agent.json"
        template "morning.yml.tt", "app/agents/#{file_name}/schedules/morning.yml"

        if file_name == "weather"
          template "fetch_forecast.rb.tt", "app/agents/#{file_name}/tools/fetch_forecast.rb"
          template "post_summary.rb.tt", "app/agents/#{file_name}/tools/post_summary.rb"
          template "cities-and-units.md.tt", "app/agents/#{file_name}/skills/cities-and-units.md"
        else
          create_file "app/agents/#{file_name}/tools/.keep", ""
          create_file "app/agents/#{file_name}/skills/.keep", ""
        end
      end

      def finish
        say "\n✓ Complete agent at app/agents/#{file_name}/", :green
        say "  agent.json / instructions.md / tools / skills / schedules"
        say "  rails-agents test #{file_name}"
        say "  rails-agents deploy #{file_name}"
      end
    end
  end
end
