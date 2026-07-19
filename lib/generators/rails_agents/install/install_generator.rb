# frozen_string_literal: true

require "rails/generators/base"
require "rbconfig"

module RailsAgents
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Mount the Rails Agents engine and create the initializer"

      class_option :open, type: :boolean, default: nil,
                   desc: "Open /agents in the browser after install"

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
        say "  Restart your Rails server so /agents is loaded:", :green
        say "    bin/dev     (or: bin/rails server)", :green
        say ""
        say "  Then open the Agents UI:", :green
        say "    #{url}", :green
        say ""
        say "  What to expect:", :green
        say "  · Sign up with GitHub or email (4-digit code)", :green
        say "  · API keys land in .env (or copy from Dashboard → API keys)", :green
        say "  · Also set those keys on your production host later", :green
        say "  · Kip helps you build your first agent in chat", :green
        say "    (files land in app/agents/ — edit anytime)", :green
        say ""
        say "============================================================", :green
        say ""

        should_open =
          if options[:open].nil?
            answer = ask("Open #{url} in your browser now? [Y/n/r]")
            answer = "y" if answer.blank?
            %w[y yes r].include?(answer.strip.downcase)
          else
            options[:open]
          end

        if should_open
          say "Opening #{url} …", :green
          say "(If the page isn't up yet, restart the server first.)", :yellow
          open_in_browser(url)
        else
          say "When ready: restart the server, then open #{url}"
        end

        say ""
        say "Guide: https://rails-agent.com/docs/getting-started"
      end

      private

      def open_in_browser(url)
        host_os = RbConfig::CONFIG["host_os"]
        cmd =
          case host_os
          when /darwin/i then ["open", url]
          when /mswin|mingw|cygwin/i then ["cmd", "/c", "start", "", url]
          else ["xdg-open", url]
          end
        system(*cmd) || say("Couldn't auto-open the browser. Visit: #{url}", :yellow)
      rescue StandardError => e
        say "Couldn't auto-open the browser (#{e.message}). Visit: #{url}", :yellow
      end
    end
  end
end
