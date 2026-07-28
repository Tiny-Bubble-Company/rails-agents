<h1 align="center">Rails Agent</h1>

<p align="center">
  <strong>Fullstack AI agents for Rails — build in code, run in the cloud.</strong>
</p>

<p align="center">
  One gem install, agents as Ruby directories, BYOK model credentials,<br />
  test / deploy / monitor at <code>/agents</code>.
</p>

<p align="center">
  <a href="docs/AGENTS.md"><strong>AGENTS.md</strong></a>
  ·
  <a href="https://rails-agent.com/docs/getting-started">Getting started</a>
  ·
  <a href="https://cloud.rails-agent.com">Cloud</a>
</p>

---

## About

Rails Agent is the fullstack framework for building production AI agents in
Rails. Define agents, instructions, tools, skills, knowledge, and evals as Ruby
files in your application, then use the mounted `/agents` dashboard to test,
deploy, observe, and manage them.

Your Rails application remains the source of truth. Rails Agent Cloud provides
the model runtime, integrations, deployment infrastructure, traces, usage, and
production operations around it.

**Start here:** [rails-agent.com/docs/getting-started](https://rails-agent.com/docs/getting-started)

## The gem

`rails-agent-stack` — mountable engine at `/agents` (Sidekiq-style).

```ruby
gem "rails-agent-stack", github: "Tiny-Bubble-Company/rails-agents"
```

---

## Positioning

Rails Agent is the **fullstack agentic platform for Rails**:

| Pillar | What it means |
|--------|----------------|
| **Build in your repo** | Agents live in `app/agents/` — use your editor or an external coding agent. Read **AGENTS.md**. |
| **BYOK models** | Attach provider credentials per agent in the cloud; reference them in Ruby — no secrets in git. |
| **Test → deploy → monitor** | One `/agents` dashboard for runs, traces, evals, channels, and cost. |
| **Four taxonomy types** | Knowledge, Workflow, Operations, Monitoring |
| **Company billing** | Fixed subscription + usage at cost + transparent **1% service fee** |

---

## Quick start

```bash
bundle add rails-agent-stack
bin/rails generate rails_agents:install
bin/dev   # → http://localhost:3000/agents
```

Connect your company workspace at `/agents`, then scaffold your first **database Knowledge agent**:

```bash
bin/rails generate rails_agents:agent store_assistant --type knowledge --database
```

**Zeitwerk:** fresh installs add `config/initializers/rails_agents_autoload.rb`
so `app/agents/` and `app/agents_library/` are treated as agent assets rather
than application namespaces.

Full path for external coding agents: **[docs/AGENTS.md](docs/AGENTS.md)**

---

## Agent directory

```
app/agents/store_assistant/
├── agent.rb            # RailsAgents::KnowledgeAgent subclass
├── prompt.md           # System prompt
├── imports.yml         # Optional workspace Library attachments
├── tools/              # Optional extracted tools
├── skills/             # Composable behaviors
├── memory.rb           # Memory config
├── knowledge/          # RAG files
├── plugins/            # External connection manifests
├── channels/           # Slack, web, API, …
└── evals/              # Smoke / regression cases

app/agents_library/
├── tools/              # Ruby actions reused by multiple agents
├── skills/             # Shared multi-step behavior
├── knowledge/          # Shared documents and source definitions
└── plugins/            # Shared connection manifests
```

Keep one-off capabilities inside the agent. Move stable capabilities to
`app/agents_library/` when another agent should reuse the same implementation,
then reference them from that agent's `imports.yml`. `rails-agents sync`
includes imported Library files in the agent runtime bundle without duplicating
the shared source in Git.

---

## Model DSL (BYOK)

```ruby
class StoreAssistant < RailsAgents::KnowledgeAgent
  model :gpt_5_mini, provider: :openai, credential: :company_openai
  memory :conversation
  knowledge_from "knowledge/**/*"

  tool :lookup_order do |order_number:|
    Order.find_by(number: order_number)&.as_json(only: %i[number status total_cents])
  end
end
```

`:company_openai` is a **cloud credential reference** — not a local env var. Legacy `model :auto` still works.

---

## Agent taxonomy

| Type | Main purpose | Example |
|------|--------------|---------|
| Knowledge | Understand and answer | Order support from Rails data |
| Workflow | Execute predictable processes | Refund approval |
| Operations | Coordinate unpredictable real-world work | Incident coordination |
| Monitoring | Observe changes and respond | Inventory watcher |

Deprecated: `ChatAgent` (→ Knowledge), `BackgroundAgent` (→ Operations).

Generator: `--type knowledge|workflow|operations|monitoring` and `--database` for DB-connected Knowledge scaffolds.
See the step-by-step guide and Ruby examples at
[rails-agent.com/docs/agent-types](https://rails-agent.com/docs/agent-types).

---

## CLI

```bash
bundle exec rails-agents run store_assistant "Where is order 42?"
bundle exec rails-agents sync store_assistant    # local → cloud (preferred)
bundle exec rails-agents deploy store_assistant
bundle exec rails-agents logs store_assistant
```

`pull` is **deprecated** (cloud authoring). Build locally; push with `sync`.

---

## Configuration

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]       # platform key
  config.project_id = ENV["RAILS_AGENTS_PROJECT_ID"]
end
```

Provider keys: cloud dashboard → Model credentials (BYOK).

---

## Pricing

| | |
|--|--|
| **Subscription** | Fixed **company** plan (production workspaces) |
| **Usage** | Provider + infrastructure at **pass-through cost** |
| **Service fee** | **1%** on metered usage (transparent line item) |

Details: [rails-agent.com/pricing](https://rails-agent.com/pricing)

---

## Development

```bash
bundle install
bundle exec rspec
```

Local path testing: see `rails-agents-boilerplate` sibling app.

---

MIT — [MIT-LICENSE](MIT-LICENSE)

[rails-agent.com](https://rails-agent.com)
