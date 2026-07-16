# Getting Started

Cloud by default. Sign up → sandbox API key → define an agent in Ruby → `.run`.

Docs home: [Rails Agents](/) · Gem: [rails-agent-stack](https://rubygems.org/gems/rails-agent-stack) · Source: [GitHub](https://github.com/Tiny-Bubble-Company/rails-agents)

## After this guide

You will know how to:

1. Create a sandbox account and API key
2. Install the gem and mount the Tool Bridge
3. Define an agent and call `.run` against Rails Agents Cloud

## 1. Sign up (sandbox)

Create an account (full name, email, company, website) in the [Cloud dashboard](https://github.com/Tiny-Bubble-Company/rails-agents-cloud) and copy:

- `RAILS_AGENTS_API_KEY` — starts with `rak_sandbox_`
- `RAILS_AGENTS_BRIDGE_SECRET` — signs Tool Bridge webhooks
- `RAILS_AGENTS_APP_ID` — your app id

You do **not** need a Vercel account, Eve CLI, or provider API keys. Models and durable runtime run on our shared cloud (Eve on Vercel) with logical sandbox isolation.

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

Expose your Rails app to the cloud Tool Bridge (ngrok/Cloudflare Tunnel in development).

## 4. Define and run an agent

```ruby
# app/agents/support_agent.rb
class SupportAgent < RailsAgents::Agent
  model "anthropic/claude-sonnet-5"
  description "Answers customer questions using account tools."
  tools "LookupAccount"
end
```

```ruby
result = SupportAgent.run("How do I reset my password?")
result.output
```

That's it. Use the dashboard playground for logs, traces, and evals. When ready, **Promote to production** (Stripe) and switch to a `rak_live_…` key.

## What's next?

- [Architecture](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/ARCHITECTURE.md) — Eve compile-to-cloud design
- [Tenancy](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/TENANCY.md) — sandbox vs production on shared infra
- [Agents](/guide/agents) · [Tools](/guide/tools) · [Community](/guide/community)
