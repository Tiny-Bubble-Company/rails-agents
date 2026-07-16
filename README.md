# Rails Agents

**Durable agents for Rails — like Eve for Ruby apps.**

Your agent is a directory. Deploy opens `/agents` on your app. First deploy signs you up and writes `.env` — nothing to configure by hand.

| | |
|---|---|
| **Docs** | [rails.meerkatagents.com](https://rails.meerkatagents.com) |
| **Gem** | [rubygems.org/gems/rails-agent-stack](https://rubygems.org/gems/rails-agent-stack) |

```bash
bundle add rails-agent-stack
bin/rails generate rails_agents:install
rails-agents new weather
rails-agents deploy weather
# → signup (first time) → .env → opens http://127.0.0.1:3000/agents
```

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

```ruby
# config/routes.rb — like Sidekiq::Web
authenticate :admin do
  mount RailsAgents::Engine => "/agents"
end
```

---

## Why this exists

Chat SDKs give you a request/response loop. Production agents need **durability**: checkpointed steps, park between messages, resume on delivery, schedules that keep running after you deploy.

That’s the Eve model. Rails Agents brings it to Rails with a Ruby-native DX and a hosted control plane — so you stay in `app/agents/`, not a second Node app.

---

## vs RubyLLM

[RubyLLM](https://rubyllm.com) is an excellent **general-purpose AI toolkit**. Rails Agents is the **agent product path**: directory → durable cloud → `/agents` dashboard.

---

## Docs

**https://rails.meerkatagents.com**
