# Getting Started

From install to a working agent in a few minutes.

Docs home: [Rails Agents](/) · Gem: [rails-agent-stack on RubyGems](https://rubygems.org/gems/rails-agent-stack) · Source: [GitHub](https://github.com/Tiny-Bubble-Company/rails-agents)

## After this guide

You will know how to:

1. Install the gem and run the generator
2. Configure API keys
3. Define an agent and call `.run`

## 1. Install

Add the gem to your Gemfile:

```ruby
# Gemfile
gem "rails-agent-stack"
```

```bash
bundle install
bin/rails generate rails_agents:install
```

The gem name is `rails-agent-stack`; the Ruby API is still `RailsAgents` (`require "rails_agents"`).

This creates:

- `config/initializers/rails_agents.rb` — API keys only
- `app/agents/` and `app/agents/tools/` — where your agents live

## 2. Configure API keys

The initializer holds **API keys only**. Models are set on each agent.

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
  config.openrouter_api_key = ENV["OPENROUTER_API_KEY"]
  config.grok_api_key = ENV["XAI_API_KEY"]
end
```

Set only the keys you use. See [Configuration](/guide/configuration) for all options.

## 3. Define and run an agent

Every agent needs three things — nothing more to get started:

```ruby
# app/agents/support_agent.rb
class SupportAgent < RailsAgents::Agent
  provider :openai                    # :openai, :anthropic, :openrouter, :grok
  model "gpt-4o-mini"                 # required — set per agent
  description "Answers customer questions using docs and account data."
  tools "SearchDocs", "LookupAccount" # optional
end
```

```bash
export OPENAI_API_KEY=sk-...
bin/rails console
```

```ruby
result = SupportAgent.run("How do I reset my password?")
result.output   # => the agent's reply
result.success  # => true/false
```

That's it. Add [tools](/guide/tools) and [skills](/guide/skills) when you need them — not before.

::: tip Free models via OpenRouter
Don't want to pay while learning? Use OpenRouter with a free model:

```ruby
class CheapAgent < RailsAgents::Agent
  provider :openrouter
  model "meta-llama/llama-3.3-70b-instruct:free"
  description "Answer briefly."
end
```
:::

## What's next?

- [Agents](/guide/agents) — the only class you need
- [Tools](/guide/tools) — wire in your app code
- [Skills](/guide/skills) — web search, spreadsheets, and more
- [Recipes](/guide/recipes) — copy-paste patterns

::: tip Built something?
[Tell us what you're building](https://github.com/Tiny-Bubble-Company/rails-agents/discussions/1) — it directly shapes the roadmap.
:::
