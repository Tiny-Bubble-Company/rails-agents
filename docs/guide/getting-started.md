# Getting Started — weather agent

```bash
bundle add rails-agent-stack
bin/rails generate rails_agents:install
rails-agents new weather
rails-agents deploy weather
```

`deploy` handles the rest: signup on Rails Agents Cloud (first run), writes credentials to `.env`, syncs the agent, and opens **`/agents`** on your Rails app so you can see agents and details.

Docs: [rails.meerkatagents.com](https://rails.meerkatagents.com)

## What you get

| Today (pain) | With Rails Agents |
|--------------|-------------------|
| Vibe-code a rake task | `instructions.md` in `app/agents/…` |
| Wire credentials by hand | `rails-agents deploy` writes `.env` |
| Cron on a worker box | `schedules/morning.yml` hosted after deploy |
| No visibility | Dashboard at `/agents` on your domain |

## 1. Install

```ruby
# Gemfile
gem "rails-agent-stack"
```

```bash
bundle install
bin/rails generate rails_agents:install
```

Mounts **`/agents`** (Sidekiq-style UI on your domain).

## 2. Create the agent folder

```bash
rails-agents new weather
```

Creates a complete agent directory:

```text
app/agents/weather/          # complete agent
  agent.json                 # the model it runs on
  instructions.md            # who it is
  tools/                     # what it can do
    fetch_forecast.rb
    post_summary.rb
  skills/                    # what it knows
    cities-and-units.md
  schedules/                 # when it acts on its own
    morning.yml
```

## 3. Deploy

```bash
rails-agents deploy weather
```

On first run the CLI prompts for signup (name + email), creates your Cloud account, saves keys to `.env`, deploys the agent, and opens:

`http://127.0.0.1:3000/agents`

There you’ll see agents, status, schedules, and details. Hosted runs need prepaid Credits (min $10) / subscription for production — add those from the dashboard when you’re ready.

## 4. Optional local check

```bash
rails-agents test weather
```

## Related

- [Agents](/guide/agents) · [Billing](/guide/billing) · [Configuration](/guide/configuration)
