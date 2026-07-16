# Rails Agents

**Durable agents for Rails — like Eve for Ruby apps.**

Your agent is a directory. An `instructions.md` is enough to start. Schedules, tools, and skills are optional building blocks. Durable execution, hosted cron, and Tool Bridge run on **[Rails Agents Cloud](https://agents.meerkatagents.com)** — so you don’t duct-tape rake tasks to Render.

| | |
|---|---|
| **Docs** | [rails.meerkatagents.com](https://rails.meerkatagents.com) |
| **Cloud** | [agents.meerkatagents.com](https://agents.meerkatagents.com) |
| **Gem** | [rubygems.org/gems/rails-agent-stack](https://rubygems.org/gems/rails-agent-stack) |
| **Architecture** | [ARCHITECTURE.md](./ARCHITECTURE.md) · [TENANCY.md](./TENANCY.md) · [PRICING.md](./PRICING.md) |

```bash
rails-agents new weather
rails-agents test weather
rails-agents deploy weather
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

---

## Why this exists

Chat SDKs give you a request/response loop. Production agents need **durability**: checkpointed steps, park between messages, resume on delivery, schedules that keep running after you deploy.

That’s the Eve model. Rails Agents brings it to Rails with a Ruby-native DX and a hosted control plane — so you stay in `app/agents/`, not a second Node app.

### What we optimize for

| Priority | In practice |
|----------|-------------|
| **Directory DX** | `instructions.md` is a complete agent (Eve-shaped) |
| **Durability** | Cloud runtime: checkpoint, park/resume, survive deploys |
| **Hosted schedules** | Cron without Render workers |
| **Rails tools** | Tool Bridge — secrets stay in your app |
| **Speed to production** | `new` → `test` → `deploy` → dashboard |

---

## vs RubyLLM

[RubyLLM](https://rubyllm.com) is an excellent **general-purpose AI toolkit** (chat, images, embeddings, persistence). You host the runtime.

| | **RubyLLM** | **Rails Agents** |
|---|-------------|------------------|
| **Job** | Full LLM SDK for Rails | **Durable production agents** |
| **Shape** | Chat + agent macros | Agent **directory** + Cloud deploy |
| **Runtime** | Your process / Sidekiq / hosts | Checkpointed cloud runs + hosted cron |
| **Ops** | You own uptime and glue | Dashboard, logs, `rails-agents deploy` |
| **Best for** | Multimodal toolkit you control | Agents that must keep running in production |

**RubyLLM** = AI toolkit. **Rails Agents** = agent product path (directory → durable cloud).

---

## Install

```ruby
# Gemfile
gem "rails-agent-stack"
```

```bash
bundle install
bin/rails generate rails_agents:install
# → mounts /agents (Sidekiq-style UI on your domain)
rails-agents new weather
```

1. Open **`/agents`** → sign up (or paste Cloud keys)  
2. Set `RAILS_AGENTS_API_KEY`, `RAILS_AGENTS_APP_ID`, `RAILS_AGENTS_BRIDGE_SECRET` in ENV  
3. Edit `app/agents/weather/instructions.md`  
4. `rails-agents test weather` → `rails-agents deploy weather`  
5. Add Credits (min $10) / subscribe for production  

```ruby
# config/routes.rb — like Sidekiq::Web
authenticate :admin do
  mount RailsAgents::Engine => "/agents"
end
```


Walkthrough: **[Getting Started](https://rails.meerkatagents.com/guide/getting-started)**

---

## Philosophy

> Fastest Rails path to a **durable** production agent — least glue, cloud runtime included.

We don’t try to be every AI feature under the sun. We ship the Eve-shaped agent loop for Rails: directory, durability, schedules, Tool Bridge, deploy.

### Who this is for

- You need agents that **survive deploys** and run on a **schedule**  
- You already have Rails code (DB, FTP, CRM) the model should call  
- You want `instructions.md` + CLI, not a second framework career  

---

## Docs & community

- [Why Rails Agents](https://rails.meerkatagents.com/guide/why)  
- [Agents](https://rails.meerkatagents.com/guide/agents) · [Billing](https://rails.meerkatagents.com/guide/billing)  
- [Discussions](https://github.com/Tiny-Bubble-Company/rails-agents/discussions)  

---

MIT © Tiny Bubble Company
