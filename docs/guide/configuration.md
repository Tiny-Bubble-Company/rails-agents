# Configuration

Cloud credentials live in the initializer. Models live on each agent.

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]                 # rak_sandbox_… or rak_live_…
  config.api_base = ENV.fetch("RAILS_AGENTS_API_BASE", "https://api.railsagents.dev")
  config.app_id = ENV["RAILS_AGENTS_APP_ID"]
  config.tool_bridge_secret = ENV["RAILS_AGENTS_BRIDGE_SECRET"]
end
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `api_key` | `ENV["RAILS_AGENTS_API_KEY"]` | Cloud API key (`rak_sandbox_` or `rak_live_`) |
| `api_base` | `https://api.railsagents.dev` | Control plane URL |
| `app_id` | `ENV["RAILS_AGENTS_APP_ID"]` | Your Cloud app id |
| `tool_bridge_secret` | `ENV["RAILS_AGENTS_BRIDGE_SECRET"]` | HMAC secret for Tool Bridge |
| `tool_bridge_path` | `/rails_agents/bridge` | Bridge path (engine default) |

Environment (`sandbox` vs `production`) is inferred from the key prefix (`rak_sandbox_` / `rak_live_`).

## Billing

Hosted `.run` requires **prepaid Credits** (dashboard top-up, min $10). Unfunded calls raise `RailsAgents::PaymentRequired`.

Optional sandbox **BYOK** (bring your own provider key) can be enabled in the dashboard for $0 hosted Gateway spend.

See [PRICING.md](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/PRICING.md).

## Install generator

```bash
bin/rails generate rails_agents:install
```

Creates:

- `config/initializers/rails_agents.rb`
- mounts `RailsAgents::Engine` at `/rails_agents`
- `app/agents/`

## Next

- [Getting Started](/guide/getting-started)
- [Agents](/guide/agents)
