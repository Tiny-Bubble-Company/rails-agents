RailsAgents.configure do |config|
  # Written automatically by `rails-agents deploy` into .env — no manual setup required.
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]
  config.api_base = ENV.fetch("RAILS_AGENTS_API_BASE", "https://agents.meerkatagents.com/api")
  config.dashboard_url = ENV.fetch("RAILS_AGENTS_DASHBOARD", "https://agents.meerkatagents.com")
  config.app_url = ENV.fetch("RAILS_AGENTS_APP_URL", "http://127.0.0.1:3000")
  config.app_id = ENV["RAILS_AGENTS_APP_ID"]
  config.tool_bridge_secret = ENV["RAILS_AGENTS_BRIDGE_SECRET"]
  config.tool_bridge_path = "/agents/bridge"

  # Optional — gate /agents like Sidekiq::Web
  # config.web_authorize = ->(controller) { controller.authenticate_user! && controller.current_user.admin? }
end
