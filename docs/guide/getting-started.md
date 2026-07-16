# Getting Started

Cloud by default. Sign up → define agents in Ruby → add Credits → `.run`.

Docs home: [Rails Agents](/) · Gem: [rails-agent-stack](https://rubygems.org/gems/rails-agent-stack) · Source: [GitHub](https://github.com/Tiny-Bubble-Company/rails-agents) · Billing: [PRICING.md](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/PRICING.md)

## After this guide

You will know how to:

1. Create a Cloud account and API key
2. Install the gem and mount the Tool Bridge
3. Define an agent
4. Fund Credits (or BYOK) and call `.run`

## 1. Sign up

Create an account (full name, email, company, website) in [Rails Agents Cloud](https://github.com/Tiny-Bubble-Company/rails-agents-cloud) and copy:

- `RAILS_AGENTS_API_KEY` — `rak_sandbox_…` (or `rak_live_…` after production)
- `RAILS_AGENTS_BRIDGE_SECRET` — signs Tool Bridge webhooks
- `RAILS_AGENTS_APP_ID` — your app id

Signup is free. **Hosted model/sandbox runs are not** — add Credits before `.run` (or use BYOK in sandbox).

You do **not** need your own Vercel account, Eve CLI, or (unless BYOK) provider keys.

## 2. Install

```ruby
# Gemfile
gem "rails-agent-stack"
```

```bash
bundle install
bin/rails generate rails_agents:install
```

This creates:

- `config/initializers/rails_agents.rb` — cloud API key + bridge secret
- mounts `RailsAgents::Engine` at `/rails_agents` (Tool Bridge)
- `app/agents/` — where your agents live

## 3. Configure

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]
  config.app_id = ENV["RAILS_AGENTS_APP_ID"]
  config.tool_bridge_secret = ENV["RAILS_AGENTS_BRIDGE_SECRET"]
end
```

Expose your Rails app so Cloud can call the Tool Bridge (ngrok/Cloudflare Tunnel in development).

## 4. Define an agent

```ruby
# app/agents/support_agent.rb
class SupportAgent < RailsAgents::Agent
  model "anthropic/claude-sonnet-5"
  description "Answers customer questions using account tools."
  tools "LookupAccount"
end
```

## 5. Fund, then run

1. In the dashboard: **Billing → Add Credits** (minimum **$10**), **or** enable sandbox **BYOK** with your own provider key.
2. Call:

```ruby
result = SupportAgent.run("How do I reset my password?")
result.output
```

If the account is unfunded, the gem raises `RailsAgents::PaymentRequired` with a checkout URL.

Usage burns **Rails Agents Credits** = underlying Vercel AI/cloud cost + margin. Production keys require a subscription + promote.

## What's next?

- [PRICING.md](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/PRICING.md) — prepaid Credits, BYOK, margins
- [ARCHITECTURE.md](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/ARCHITECTURE.md) — Eve compile-to-cloud
- [TENANCY.md](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/TENANCY.md) — sandbox vs production
- [Agents](/guide/agents) · [Tools](/guide/tools) · [Community](/guide/community)
