# Rails Agent (`rails-agent-stack`)

**Build AI agents in Rails like a walk in the park.**

The fullstack agentic platform for Rails. One gem install, chat in the dashboard, and we handle the code, infra and deploys — you focus on the business logic.

| | |
|---|---|
| **Website** | [rails-agent.com](https://rails-agent.com) |
| **Get started** | [rails-agent.com/start](https://rails-agent.com/start) |
| **Cloud** | [cloud.rails-agent.com](https://cloud.rails-agent.com) |
| **Gem** | `rails-agent-stack` |

---

## Get started

Same steps as [rails-agent.com/start](https://rails-agent.com/start). Don't sign up on the website first — start in your Rails app.

### 01 · Add the gem

In your Rails app `Gemfile`:

```ruby
gem "rails-agent-stack", github: "Tiny-Bubble-Company/rails-agents"
```

### 02 · Install

Bundle, then run the installer. It mounts the engine and prepares credentials.

```bash
bundle install
bin/rails generate rails_agents:install
```

### 03 · Restart your Rails server

Restart so the new mount is loaded. The Agents UI is at `/agents` — like Sidekiq.

```bash
bin/dev
# or: bin/rails server

# → http://localhost:3000/agents
```

### What to expect

1. The Agents UI loads at **`/agents`** (e.g. `http://localhost:3000/agents`).
2. Sign up with **GitHub** or **email** (4-digit code), then paste your sandbox API key to connect this app.
3. After signup, **Kip** — your docs-free coding agent — helps you build your first agent in chat. Describe what it should do; Kip writes `app/agents/`. Edit those files anytime if you want.

Works with **Rails 7+** · **Ruby 3.2+** · cloud runtime included.

---

## Why Rails Agent?

| Pillar | What it means |
|--------|----------------|
| **Zero AI knowledge** | You don't need LLMs, embeddings, or prompt engineering. If you can write Rails, you can ship agents. |
| **Zero config** | No API keys, no vector DB, no Redis, no Vercel setup. Install the gem — we run the stack. |
| **Meet Kip** | Kip is the inbuilt coding agent that knows Rails Agent. Chat with Kip — it builds `app/agents/` for you. No new framework syntax to learn. Edit the code anytime if you want. |
| **Build → test → deploy → monitor** | One platform for the whole lifecycle. |
| **Scalable agentic infra** | Hosted runtime, autoscaling, retries, tracing — included. |
| **Unified debugging** | Every trace, log, error, and cost is searchable in `/agents`. |

---

## How it works

1. **Add the gem** → `bundle install` → `bin/rails generate rails_agents:install`.
2. **Restart** the server and open `/agents`.
3. **Sign up** once — credentials stay on disk.
4. **Chat with Kip** to build your first agent (`app/agents/<name>/`).
5. **Test** in the sandbox, then **deploy** channels (Slack, web chat, cron, …).

---

## Agent-as-directory

```bash
bin/rails generate rails_agents:agent support
# or
bundle exec rails-agents new support
```

```
app/agents/support/
├── agent.rb            # RailsAgents::Base subclass
├── prompt.md           # system prompt
├── tools/              # tool definitions
├── skills/             # composable behaviors
├── memory.rb           # memory config
├── knowledge/          # RAG files synced to cloud
├── channels/           # slack.rb, web_chat.rb, ...
└── evals/              # eval cases
```

### DSL example

```ruby
class Support < RailsAgents::Base
  model :auto
  memory :conversation
  knowledge_from "knowledge/**/*"

  tool :lookup_order do |order_id:|
    Order.find(order_id).as_json
  end

  skill :triage, from: "skills/triage.rb"
  channel :slack
end
```

```bash
bundle exec rails-agents run support "Where is order 42?"
bundle exec rails-agents deploy support
bundle exec rails-agents pull support
bundle exec rails-agents logs support
```

---

## Configuration

The gem always talks to **https://cloud.rails-agent.com** — no base URL env vars.

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]
  config.project_id = ENV["RAILS_AGENTS_PROJECT_ID"]
end
```

```bash
# .env (local) and your production host env
RAILS_AGENTS_API_KEY=rak_sandbox_…
RAILS_AGENTS_PROJECT_ID=prj_…
```

Connecting from `/agents` (or `rails-agents login`) writes these for you. If they are missing, copy them from [Dashboard → API keys](https://cloud.rails-agent.com/dashboard/keys). Also set the same vars on your production server before deploy.

---

## Engine

`/agents` is Sidekiq-simple: signup → API key on disk → iframe of the cloud dashboard.

When you vibecode (or hit **Test** / **Deploy**) inside that iframe, the cloud messages the parent page. `POST /agents/pull` fetches files and writes them into `app/agents/<slug>/` on your machine.

---

## Pricing (cloud)

| Plan | |
|------|--|
| **Developer** | Free sandbox for build & test |
| **Studio** | $49/dev/mo — production deploys & channels |
| **Enterprise** | Custom |

Details: [rails-agent.com/pricing](https://rails-agent.com/pricing)

---

## Development (this repo)

```bash
bundle install
bundle exec rspec
```

Local path testing (see `rails-agents-boilerplate` sibling app):

```ruby
gem "rails-agent-stack", path: "../rails-agents", require: "rails_agents"
```

---

## License

MIT — see [MIT-LICENSE](MIT-LICENSE).

---

Built for Rails developers, by people who'd rather write Ruby than YAML prompts. Kip approves.
