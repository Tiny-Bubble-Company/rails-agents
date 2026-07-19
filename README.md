# Rails Agent (`rails-agent-stack`)

**Rails-native AI agents.** One gem. One mount. Zero API keys.

Meet **Kip**, the meerkat who keeps watch while your agents run on [Rails Agent Cloud](https://meerkatagents.com). Define agents in Ruby, deploy to Slack and beyond, and monitor every run — without prompt-engineering rabbit holes or vector DB decisions.

- **Website & dashboard:** [meerkatagents.com](https://meerkatagents.com)
- **Docs:** [Getting started](https://meerkatagents.com/docs/getting-started)
- **GitHub:** [Tiny-Bubble-Company/rails-agents](https://github.com/Tiny-Bubble-Company/rails-agents)

## Why Rails Agent?

- **Zero AI knowledge** — models, embeddings, memory, and tool sandboxing are cloud-managed.
- **Rails-native** — mount `/agents` like Sidekiq, scaffold `app/agents/<name>/`, use `RailsAgents::Base`.
- **Build → deploy → monitor** — chat authoring, logs, traces, evals, and channel deploys in one dashboard.

## Install

```bash
bundle add rails-agent-stack
rails generate rails_agents:install
bin/dev
# open http://localhost:3000/agents
```

The generator mounts `RailsAgents::Engine` at `/agents` and writes `config/initializers/rails_agents.rb`.

### Connect to cloud

**Option A — browser (recommended)**  
Visit `/agents`, sign up with email/password. The engine handshakes with meerkatagents.com, writes `config/rails_agents_credentials.yml`, and embeds your dashboard.

**Option B — CLI**

```bash
rails-agents login
# prints:
# export RAILS_AGENTS_API_KEY=ra_…
# export RAILS_AGENTS_PROJECT_ID=ten_…
```

## Configuration

```ruby
RailsAgents.configure do |config|
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]
  config.api_base = ENV.fetch("RAILS_AGENTS_API_BASE", "https://meerkatagents.com")
  config.dashboard_base = ENV.fetch("RAILS_AGENTS_DASHBOARD_BASE", "https://meerkatagents.com")
  config.project_id = ENV["RAILS_AGENTS_PROJECT_ID"]
end
```

API routes live at the same origin under `/api/v1`. Cloud-only for MVP — no BYOK, no self-hosting.

## Agent-as-directory

```bash
rails generate rails_agents:agent support
# or
rails-agents new support
```

```
app/agents/support/
├── agent.rb            # RailsAgents::Base subclass
├── prompt.md           # system prompt
├── tools/              # tool definitions
├── skills/             # composable behaviors
├── memory.rb           # memory config
├── knowledge/          # RAG files synced to cloud
├── channels/           # slack.rb, discord.rb, ...
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
rails-agents run support "Where is order 42?"
rails-agents deploy support
rails-agents sync support   # local → cloud
rails-agents pull agt_…     # cloud → app/agents/<slug>/
rails-agents logs support
```

## Engine

`/agents` is Sidekiq-simple: signup handshake → credentials on disk → iframe of the cloud dashboard (`?embed=1&token=…`).

When you vibecode (or hit **Test** / **Deploy**) inside that iframe, the cloud posts a message to the parent page. The gem’s `POST /agents/pull` fetches files from the API and writes them into `app/agents/<slug>/` on this machine — no Cursor install, no manual sync for the happy path.

## Cloud API client

| Method | Endpoint |
|--------|----------|
| `POST` | `/api/v1/auth/handshake` |
| `POST` | `/api/v1/runs` |
| `PUT`  | `/api/v1/agents/:id/files` |
| `POST` | `/api/v1/deploys` |
| `POST` | `/api/v1/channels/:kind/install` |
| `POST` | `/api/v1/knowledge/sync` |
| `GET`  | `/api/v1/logs`, `/traces`, `/evals` |

## Namespace

The gem module is `RailsAgents`. Prefer `RailsAgents::Base` everywhere.

## Development

```bash
bundle install
bundle exec rspec
```

## License

MIT — see [MIT-LICENSE](MIT-LICENSE).

---

Built for Rails developers, by people who'd rather write Ruby than YAML prompts. Kip approves.
