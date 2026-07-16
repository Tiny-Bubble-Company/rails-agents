# frozen_string_literal: true

require_relative "env_file"

module RailsAgents
  class Configuration
    DEFAULT_API_BASE = "https://agents.meerkatagents.com/api"
    DEFAULT_DASHBOARD_URL = "https://agents.meerkatagents.com"

    attr_accessor :api_key, :api_base, :tool_bridge_secret, :tool_bridge_path,
      :app_id, :default_environment, :dashboard_url, :web_authorize, :app_url,
      # Legacy v0.1 fields kept for gem load compatibility; unused in cloud-only mode.
      :openai_api_key, :anthropic_api_key, :openrouter_api_key, :grok_api_key,
      :default_provider, :anthropic_auto_download_files, :anthropic_files_directory

    def initialize
      load_dotenv_if_present!

      @api_key = ENV["RAILS_AGENTS_API_KEY"]
      @api_base = ENV.fetch("RAILS_AGENTS_API_BASE", DEFAULT_API_BASE)
      @tool_bridge_secret = ENV["RAILS_AGENTS_BRIDGE_SECRET"]
      @tool_bridge_path = ENV.fetch("RAILS_AGENTS_BRIDGE_PATH", "/agents/bridge")
      @app_id = ENV["RAILS_AGENTS_APP_ID"]
      @dashboard_url = ENV.fetch("RAILS_AGENTS_DASHBOARD", DEFAULT_DASHBOARD_URL)
      @app_url = ENV.fetch("RAILS_AGENTS_APP_URL", "http://127.0.0.1:3000")
      @web_authorize = nil
      @default_environment = nil

      @openai_api_key = ENV["OPENAI_API_KEY"]
      @anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
      @openrouter_api_key = ENV["OPENROUTER_API_KEY"]
      @grok_api_key = ENV["XAI_API_KEY"] || ENV["GROK_API_KEY"]
      @default_provider = :openai
      @anthropic_auto_download_files = true
      @anthropic_files_directory = nil
    end

    def require_api_key!
      return api_key if api_key.to_s != ""

      raise ConfigurationError,
        "No Cloud credentials yet. Run `rails-agents deploy <agent>` - " \
        "it signs you up and writes keys to .env automatically."
    end

    def environment
      return default_environment.to_s if default_environment

      case api_key.to_s
      when /\Arak_live_/ then "production"
      when /\Arak_sandbox_/ then "sandbox"
      else "sandbox"
      end
    end

    def anthropic_files_directory!
      return Pathname.new(@anthropic_files_directory) if @anthropic_files_directory.to_s != ""
      return Rails.root.join("tmp/rails_agents/files") if defined?(::Rails) && ::Rails.respond_to?(:root)

      Pathname.new(Dir.mktmpdir("rails_agents_files_"))
    end

    def apply_credentials!(api_key:, app_id:, bridge_secret:)
      @api_key = api_key
      @app_id = app_id
      @tool_bridge_secret = bridge_secret
      ENV["RAILS_AGENTS_API_KEY"] = api_key.to_s
      ENV["RAILS_AGENTS_APP_ID"] = app_id.to_s
      ENV["RAILS_AGENTS_BRIDGE_SECRET"] = bridge_secret.to_s
    end

    private

    def load_dotenv_if_present!
      root =
        if defined?(::Rails) && ::Rails.respond_to?(:root) && ::Rails.root
          ::Rails.root
        else
          Pathname.pwd
        end
      EnvFile.load!(root)
    rescue NameError
      # EnvFile not loaded yet during boot — Railtie / CLI loads it explicitly.
    end
  end
end
