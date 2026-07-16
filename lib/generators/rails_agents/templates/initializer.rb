RailsAgents.configure do |config|
  # Cloud-only. Sign up at /agents (mounted below) or https://agents.meerkatagents.com/signup
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]                 # rak_sandbox_… or rak_live_…
  config.api_base = ENV.fetch("RAILS_AGENTS_API_BASE", "https://agents.meerkatagents.com/api")
  config.dashboard_url = ENV.fetch("RAILS_AGENTS_DASHBOARD", "https://agents.meerkatagents.com")
  config.app_id = ENV["RAILS_AGENTS_APP_ID"]
  config.tool_bridge_secret = ENV["RAILS_AGENTS_BRIDGE_SECRET"]
  # Tool Bridge path when engine is mounted at /agents
  config.tool_bridge_path = "/agents/bridge"

  # Sidekiq-style: gate /agents behind your own auth (recommended in production).
  # config.web_authorize = ->(controller) { controller.authenticate_user! && controller.current_user.admin? }
end
