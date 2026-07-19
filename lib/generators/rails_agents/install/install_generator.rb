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

      def show_next_steps
        return unless behavior == :invoke

        port = ENV.fetch("PORT", "3000")
        url = "http://localhost:#{port}/agents"

        say ""
        say "============================================================", :green
        say "  Rails Agents installed", :green
        say "============================================================", :green
        say ""
        say "  1. Start your app:  bin/dev   (or rails s)", :green
        say "  2. Open this URL:   #{url}", :green
        say ""
        say "  Sign up with GitHub or email (we'll email a 4-digit code).", :green
        say "  Then vibe-code your first agent — files land in app/agents/.", :green
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
          open_in_browser(url)
        else
          say "When ready, open: #{url}"
        end

        say ""
        say "Docs: https://meerkatagents.com/docs/getting-started"
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
