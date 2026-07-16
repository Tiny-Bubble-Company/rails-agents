# frozen_string_literal: true

module RailsAgents
  # Base for the Sidekiq-style Web UI mounted at /agents.
  class WebController < ActionController::Base
    protect_from_forgery with: :exception
    layout "rails_agents/web"

    before_action :authorize_web!

    helper_method :dashboard_url, :connected?, :environment_label

    private

    def authorize_web!
      auth = RailsAgents.config.web_authorize
      return if auth.nil?

      allowed = auth.call(self)
      return if allowed

      render plain: "Unauthorized — configure RailsAgents.config.web_authorize or wrap the mount in authenticate.",
        status: :unauthorized
    end

    def dashboard_url
      RailsAgents.config.dashboard_url.to_s.sub(%r{/\z}, "")
    end

    def connected?
      effective_api_key.to_s.start_with?("rak_")
    end

    def environment_label
      case effective_api_key.to_s
      when /\Arak_live_/ then "production"
      when /\Arak_sandbox_/ then "sandbox"
      else "—"
      end
    end

    def effective_api_key
      session[:rails_agents_api_key].presence || RailsAgents.config.api_key
    end

    def effective_app_id
      session[:rails_agents_app_id].presence || RailsAgents.config.app_id
    end

    def effective_bridge_secret
      session[:rails_agents_bridge_secret].presence || RailsAgents.config.tool_bridge_secret
    end

    def cloud_client
      Cloud::Client.new(config: runtime_config)
    end

    def runtime_config
      cfg = RailsAgents.config.dup
      cfg.api_key = effective_api_key
      cfg.app_id = effective_app_id
      cfg.tool_bridge_secret = effective_bridge_secret
      cfg
    end

    def store_credentials!(api_key:, app_id:, bridge_secret:)
      session[:rails_agents_api_key] = api_key
      session[:rails_agents_app_id] = app_id
      session[:rails_agents_bridge_secret] = bridge_secret
    end
  end
end
