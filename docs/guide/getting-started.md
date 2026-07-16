# Getting Started — Accidental Damage Cover → FTP (the reference job)

Replace rake + Render cron with:

```bash
bundle add rails-agent-stack
bin/rails generate rails_agents:install
rails-agents new accidental_damage_sync
# edit app/agents/accidental_damage_sync/instructions.md
rails-agents test accidental_damage_sync
rails-agents deploy accidental_damage_sync
```

Docs: [rails.meerkatagents.com](https://rails.meerkatagents.com) · Cloud: [agents.meerkatagents.com](https://agents.meerkatagents.com)

## What you get

| Today (pain) | With Rails Agents |
|--------------|-------------------|
| Vibe-code a rake task | `instructions.md` in `app/agents/…` |
| Deploy to Render | `rails-agents deploy` |
| Cron on Render | `schedules/poll.yml` hosted after deploy |
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

## 2. Create the agent folder

```bash
rails-agents new accidental_damage_sync
```

Creates:

```text
app/agents/accidental_damage_sync/
  instructions.md      # your sync rules (complete agent)
  agent.json
  schedules/poll.yml   # hosted cron
  tools/               # optional Tool Bridge helpers
```

Edit `instructions.md` for your collection fields, FTP layout, and idempotency rules. Implement Tool Bridge tools in Rails (`ListNewAgreements`, `UploadFtp`, …).

## 3. Test locally

```bash
rails-agents test accidental_damage_sync          # validate folder (no Cloud)
rails-agents test accidental_damage_sync --live   # sandbox run (needs API key + Credits)
```

## 4. Deploy to production

```bash
rails-agents deploy accidental_damage_sync
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
