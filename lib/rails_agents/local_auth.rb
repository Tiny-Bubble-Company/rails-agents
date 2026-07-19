# frozen_string_literal: true

require "active_support/concern"

module RailsAgents
  module LocalAuth
    extend ActiveSupport::Concern

    private

    def local_return_url
      port = (request.port.presence || 3000).to_s
      return nil unless %w[localhost 127.0.0.1].include?(request.host)

      "http://127.0.0.1:#{port}#{rails_agents.connect_path}"
    end

    def github_oauth_url
      cloud = RailsAgents.config.dashboard_base.to_s.chomp("/")
      cloud = "https://cloud.rails-agent.com" if cloud.blank?
      return_to = "/dashboard"
      url = "#{cloud}/api/v1/auth/github?return_to=#{ERB::Util.url_encode(return_to)}"
      lr = local_return_url
      url = "#{url}&local_return=#{ERB::Util.url_encode(lr)}" if lr
      url
    end

    def complete_cloud_auth!(response)
      data = response.is_a?(Hash) ? response : {}
      api_key =
        data.dig("apiKey", "token") ||
        (data["apiKey"].is_a?(String) ? data["apiKey"] : nil) ||
        data["api_key"]
      project_id = data.dig("project", "id") || data["projectId"] || data["project_id"]
      embed_token = data["embedToken"] || data["embed_token"]

      raise Client::Error.new("No API key returned from Cloud") if api_key.blank?

      CredentialsWriter.write!(api_key: api_key, project_id: project_id)
      RailsAgents.configure do |config|
        config.api_key = api_key
        config.project_id = project_id if project_id
      end

      redirect_to rails_agents.dashboard_path(embed_token: embed_token),
                  notice: "Connected. Welcome to Rails Agent."
    end

    def redirect_if_configured!
      return unless configured?

      redirect_to rails_agents.root_path
    end
  end
end
