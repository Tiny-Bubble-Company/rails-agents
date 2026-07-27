# frozen_string_literal: true

module RailsAgents
  class Configuration
    # Always Rails Agent Cloud. Not overridable via ENV.
    DEFAULT_ORIGIN = "https://cloud.rails-agent.com"

    attr_accessor :api_key, :project_id
    attr_reader :api_base, :dashboard_base

    def initialize
      @api_key = ENV["RAILS_AGENTS_API_KEY"]
      @project_id = ENV["RAILS_AGENTS_PROJECT_ID"]
      @api_base = DEFAULT_ORIGIN
      @dashboard_base = DEFAULT_ORIGIN
    end

    # Kept for tests / rare overrides; production apps should not set these.
    def api_base=(value)
      stripped = value.to_s.strip
      @api_base = stripped.empty? ? DEFAULT_ORIGIN : stripped
    end

    def dashboard_base=(value)
      stripped = value.to_s.strip
      @dashboard_base = stripped.empty? ? DEFAULT_ORIGIN : stripped
    end

    def configured?
      api_key.to_s.strip != ""
    end

    def api_v1_base
      base = api_base.to_s.chomp("/")
      return base if base.end_with?("/api/v1")
      return "#{base}/v1" if base.end_with?("/api")

      "#{base}/api/v1"
    end
  end
end
