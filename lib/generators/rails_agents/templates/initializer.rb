RailsAgents.configure do |config|
  # Cloud-only. Get keys from the Rails Agents dashboard after signup.
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]                 # rak_sandbox_… or rak_live_…
  config.api_base = ENV.fetch("RAILS_AGENTS_API_BASE", "https://api.railsagents.dev")
  config.app_id = ENV["RAILS_AGENTS_APP_ID"]
  config.tool_bridge_secret = ENV["RAILS_AGENTS_BRIDGE_SECRET"]
end
