# Configuration

Cloud credentials live in the initializer. The Sidekiq-style UI mounts at `/agents`.

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]                 # rak_sandbox_… or rak_live_…
  config.api_base = ENV.fetch("RAILS_AGENTS_API_BASE", "https://agents.meerkatagents.com/api")
  config.dashboard_url = ENV.fetch("RAILS_AGENTS_DASHBOARD", "https://agents.meerkatagents.com")
  config.app_id = ENV["RAILS_AGENTS_APP_ID"]
  config.tool_bridge_secret = ENV["RAILS_AGENTS_BRIDGE_SECRET"]
  config.tool_bridge_path = "/agents/bridge"

  # Optional — gate /agents like Sidekiq::Web
  # config.web_authorize = ->(controller) { controller.authenticate_user! }
end
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `api_key` | `ENV["RAILS_AGENTS_API_KEY"]` | Cloud API key (`rak_sandbox_` or `rak_live_`) |
| `api_base` | `https://agents.meerkatagents.com/api` | Control plane URL |
| `dashboard_url` | `https://agents.meerkatagents.com` | Cloud dashboard / signup |
| `app_id` | `ENV["RAILS_AGENTS_APP_ID"]` | Your Cloud app id |
| `tool_bridge_secret` | `ENV["RAILS_AGENTS_BRIDGE_SECRET"]` | HMAC secret for Tool Bridge |
| `tool_bridge_path` | `/agents/bridge` | Bridge path (engine default) |
| `web_authorize` | `nil` | Optional `->(controller) { … }` gate for `/agents` |

Environment (`sandbox` vs `production`) is inferred from the key prefix (`rak_sandbox_` / `rak_live_`).

## `/agents` Web UI (like Sidekiq)

```ruby
# config/routes.rb
mount RailsAgents::Engine => "/agents"

# Recommended in production:
authenticate :admin do
  mount RailsAgents::Engine => "/agents"
end
```

Visit `https://your-app.com/agents` to:

1. Sign up (server-side to Cloud) or paste existing keys  
2. See agents, status, schedules, credits  
3. Jump into full Cloud billing / agent detail when needed  

Tool Bridge stays at `POST /agents/bridge`.

## Billing

Hosted `.run` requires **prepaid Credits** (dashboard top-up, min $10). Unfunded calls raise `RailsAgents::PaymentRequired`.

See [PRICING.md](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/PRICING.md).

## Install generator

```bash
bin/rails generate rails_agents:install
```

Creates:

- `config/initializers/rails_agents.rb`
- mounts `RailsAgents::Engine` at `/agents`
- `app/agents/`

## Next

- [Getting Started](/guide/getting-started)
- [Agents](/guide/agents)
