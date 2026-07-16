# Getting Started — weather agent (the reference job)

Create a durable agent in one directory:

```bash
bundle add rails-agent-stack
bin/rails generate rails_agents:install
# open https://your-app.com/agents → sign up (Sidekiq-style UI on your domain)
rails-agents new weather
# edit app/agents/weather/instructions.md
rails-agents test weather
rails-agents deploy weather
```

Docs: [rails.meerkatagents.com](https://rails.meerkatagents.com) · Cloud: [agents.meerkatagents.com](https://agents.meerkatagents.com)

The installer mounts **`/agents`** — signup, agent list, and Cloud links on your own domain (like Sidekiq’s `/sidekiq`).

## What you get

| Today (pain) | With Rails Agents |
|--------------|-------------------|
| Vibe-code a rake task | `instructions.md` in `app/agents/…` |
| Deploy glue yourself | `rails-agents deploy` |
| Cron on a worker box | `schedules/morning.yml` hosted after deploy |
| No visibility | Dashboard: status, runs, logs |

## 1. Install

```ruby
# Gemfile
gem "rails-agent-stack"
```

```bash
bundle install
bin/rails generate rails_agents:install
```

Open **`/agents`** in your app → create an account (or paste keys). Copy credentials into ENV.

## 2. Create the agent folder

```bash
rails-agents new weather
```

Creates:

```text
app/agents/weather/
  instructions.md      # who it is (complete agent)
  agent.json
  schedules/morning.yml
  tools/               # optional Tool Bridge helpers
```

Edit `instructions.md` for cities, tone, and tools. Implement Tool Bridge tools in Rails (`FetchForecast`, `PostSummary`, …).

## 3. Test locally

```bash
rails-agents test weather          # validate folder (no Cloud)
rails-agents test weather --live   # sandbox run (needs API key + Credits)
```

## 4. Deploy to production

```bash
rails-agents deploy weather
```

If you have no Cloud account yet, the CLI opens signup. Production deploy requires:

1. Account + **subscription** (dashboard Billing)
2. Prepaid **Credits** (min $10)

Then the CLI syncs the directory, marks the agent deployed, and opens the dashboard with status + telemetry.

```bash
# .env
RAILS_AGENTS_API_KEY=rak_live_…
RAILS_AGENTS_APP_ID=app_…
RAILS_AGENTS_BRIDGE_SECRET=…
# optional override:
# RAILS_AGENTS_API_BASE=https://agents.meerkatagents.com/api
```

## 5. Dashboard

- Agents list — status (`draft` / `deployed`), env, schedule, last run  
- Agent detail — run history + log lines  
- Billing — subscribe + Credits  

## Related

- [Agents](/guide/agents) · [Billing](/guide/billing) · [PRICING.md](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/PRICING.md)
