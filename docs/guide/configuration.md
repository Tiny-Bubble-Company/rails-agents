# Configuration

Most apps need **zero manual config**. `rails-agents deploy` signs up (first time), writes `.env`, and opens `/agents`.

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  # Loaded automatically from .env after `rails-agents deploy`
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]
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
| `api_key` | from `.env` via deploy | Cloud API key |
| `api_base` | `https://agents.meerkatagents.com/api` | Control plane |
| `dashboard_url` | `https://agents.meerkatagents.com` | Cloud origin for signup API |
| `app_url` | `http://127.0.0.1:3000` | Where deploy opens `/agents` |
| `app_id` / `tool_bridge_secret` | from `.env` via deploy | Tenant + HMAC |
| `tool_bridge_path` | `/agents/bridge` | Bridge path |
| `web_authorize` | `nil` | Optional gate for `/agents` |

Override the opened app URL with `RAILS_AGENTS_APP_URL` if your server isn’t on port 3000.

## `/agents` Web UI

```ruby
mount RailsAgents::Engine => "/agents"
```

Visit `/agents` after deploy to see agents and details on your domain.

## Billing

Hosted `.run` requires prepaid Credits (min $10). See [Billing](/guide/billing).

## Install generator

```bash
bin/rails generate rails_agents:install
```
