# Rails Agent (`rails-agent-stack`)

**Build AI agents in Rails like a walk in the park.**

The fullstack agentic platform for Rails. One gem install, chat in the dashboard, and we handle the code, infra and deploys — you focus on the business logic.

| | |
|---|---|
| **Website** | [rails-agent.com](https://rails-agent.com) |
| **Get started** | [rails-agent.com/start](https://rails-agent.com/start) |
| **Docs** | [Getting started](https://rails-agent.com/docs/getting-started) |
| **Gem** | `rails-agent-stack` |

Meet **Kip**, the meerkat who keeps watch while your agents run on Rails Agent Cloud.

---

## Get started

Don't sign up on the website first. Install the gem, run one command, then create your account at `/agents` — like Sidekiq.

**1. Add the gem** to your Rails app `Gemfile`:

```ruby
gem "rails-agent-stack", github: "Tiny-Bubble-Company/rails-agents"
```

**2. Install:**

```bash
bundle install
bin/rails generate rails_agents:install
```

The installer mounts `/agents`, prints `http://localhost:3000/agents`, and can open your browser (`Y` / `r`).

```bash
bin/dev
# open http://localhost:3000/agents
```

Sign up with **GitHub** or **email** (4-digit code), paste your sandbox API key, then vibe-code your first agent. Files land in `app/agents/<name>/`.

Works with **Rails 7+** · **Ruby 3.2+** · cloud runtime included.

---

## Why Rails Agent?

| Pillar | What it means |
|--------|----------------|
| **Zero AI knowledge** | You don't need LLMs, embeddings, or prompt engineering. If you can write Rails, you can ship agents. |
| **Zero config** | No API keys, no vector DB, no Redis, no Vercel setup. Install the gem — we run the stack. |
| **Vibe coding** | Describe what you want in the dashboard chat. Kip scaffolds the agent folder in your repo. |
| **Build → test → deploy → monitor** | One platform for the whole lifecycle. |
| **Scalable agentic infra** | Hosted runtime, autoscaling, retries, tracing — included. |
| **Unified debugging** | Every trace, log, error, and cost is searchable in `/agents`. |

---

## How it works

1. **Install** the gem and open `/agents` (Sidekiq-style mount).
2. **Sign up** once — credentials stay on disk.
3. **Vibe-code** an agent in the embedded dashboard.
4. **Pull** files into `app/agents/<name>/` automatically from the iframe.
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
