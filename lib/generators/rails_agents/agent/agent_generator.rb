# frozen_string_literal: true

require "rails/generators"

module RailsAgents
  module Generators
    class AgentGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      desc "Create Eve-shaped agent: app/agents/NAME/instructions.md + schedule"

      def create_agent_directory
        empty_directory "app/agents/#{file_name}"
        empty_directory "app/agents/#{file_name}/schedules"
        empty_directory "app/agents/#{file_name}/tools"
        template "instructions.md.tt", "app/agents/#{file_name}/instructions.md"
        template "agent.json.tt", "app/agents/#{file_name}/agent.json"
        template "morning.yml.tt", "app/agents/#{file_name}/schedules/morning.yml"
        create_file "app/agents/#{file_name}/tools/.keep", ""
      end

      def finish
        say "\n✓ Agent created at app/agents/#{file_name}/", :green
        say "  rails-agents test #{file_name}"
        say "  rails-agents deploy #{file_name}"
      end
    end
  end
end
