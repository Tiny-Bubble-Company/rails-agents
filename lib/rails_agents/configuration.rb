# frozen_string_literal: true

module RailsAgents
  class Configuration
    DEFAULT_ORIGIN = "https://meerkatagents.com"

    attr_accessor :api_key, :api_base, :dashboard_base, :project_id

    def initialize
      @api_key = ENV["RAILS_AGENTS_API_KEY"]
      @api_base = ENV.fetch("RAILS_AGENTS_API_BASE", DEFAULT_ORIGIN)
      @dashboard_base = ENV.fetch("RAILS_AGENTS_DASHBOARD_BASE", DEFAULT_ORIGIN)
      @project_id = ENV["RAILS_AGENTS_PROJECT_ID"]
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
