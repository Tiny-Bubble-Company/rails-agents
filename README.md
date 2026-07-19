# Rails Agent (`rails-agent-stack`)

**Build AI agents in Rails like a walk in the park.**

Fully **documentation-free**. Meet **Kip** — your built-in coding agent that already knows Rails Agent. Describe what you want in chat; Kip writes `app/agents/` for you. No new framework syntax to learn (edit those Ruby files anytime if you want).

| | |
|---|---|
| **Website** | [rails-agent.com](https://rails-agent.com) |
| **Get started** | [rails-agent.com/start](https://rails-agent.com/start) |
| **Cloud** | [cloud.rails-agent.com](https://cloud.rails-agent.com) |
| **Gem** | `rails-agent-stack` |

---

## Get started

Don't sign up on the website first. Add the gem, install, **restart your Rails server**, then open `/agents`.

**1. Add the gem** to your Rails app `Gemfile`:

```ruby
gem "rails-agent-stack", github: "Tiny-Bubble-Company/rails-agents"
```

**2. Install:**

```bash
bundle install
bin/rails generate rails_agents:install
```

**3. Restart your Rails server** so `/agents` is loaded:

```bash
bin/dev
# or: bin/rails server

# → http://localhost:3000/agents
```

### What to expect

1. The Agents UI loads at **`/agents`** (Sidekiq-style).
2. Sign up with **GitHub** or **email** (4-digit code), then paste your sandbox API key.
3. After signup, **Kip** helps you build your first agent in chat — describe what it should do; files land in `app/agents/<name>/`.

Works with **Rails 7+** · **Ruby 3.2+** · cloud runtime included.

---

## Why Rails Agent?

| Pillar | What it means |
|--------|----------------|
| **Documentation-free** | Skip the docs and DSL tutorials. Kip already knows Rails Agent and implements agents in chat. |
| **Zero AI knowledge** | You don't need LLMs, embeddings, or prompt engineering — describe the job in English. |
| **Zero config** | No API keys, no vector DB, no Redis, no Vercel setup. Install the gem — we run the stack. |
| **Chat is the IDE** | Kip builds `app/agents/` for you. Prefer the keyboard? Edit those files anytime. |
| **Build → test → deploy → monitor** | One platform for the whole lifecycle. |
| **Unified debugging** | Every trace, log, error, and cost is searchable in `/agents`. |

---

## How it works

1. **Install** the gem, restart the server, open `/agents`.
2. **Sign up** once — credentials stay on disk.
3. **Chat with Kip** to define your first agent.
4. **Pull** files into `app/agents/<name>/` automatically.
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

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]
  config.api_base = ENV.fetch("RAILS_AGENTS_API_BASE", "https://cloud.rails-agent.com")
  config.dashboard_base = ENV.fetch("RAILS_AGENTS_DASHBOARD_BASE", "https://cloud.rails-agent.com")
  config.project_id = ENV["RAILS_AGENTS_PROJECT_ID"]
end
```

After you connect from `/agents`, credentials are also written to `config/rails_agents_credentials.yml`.

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
