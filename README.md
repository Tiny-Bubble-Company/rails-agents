<p align="center">
  <a href="https://rails-agent.com">
    <img src="https://rails-agent.com/og-image.jpg" alt="Rails Agent — fullstack AI agents for Ruby on Rails" width="720" />
  </a>
</p>

<h1 align="center">Rails Agent</h1>

<p align="center">
  <strong>A single, beautiful full-stack agentic platform for Ruby on Rails.</strong><br />
  Build, test, deploy, and monitor production AI agents at <code>/agents</code>.
</p>

<p align="center">
  <a href="https://rails-agent.com"><img src="https://img.shields.io/badge/rails--agent.com-docs-C2410C?style=flat-square" alt="Docs" /></a>
  <a href="https://github.com/Tiny-Bubble-Company/rails-agents"><img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT" /></a>
  <a href="https://rails-agent.com/docs/getting-started"><img src="https://img.shields.io/badge/Ruby-3.2%2B-CC342D?style=flat-square&logo=ruby&logoColor=white" alt="Ruby 3.2+" /></a>
  <a href="docs/RAILS_SUPPORT.md"><img src="https://img.shields.io/badge/Rails-6.1%2B-D30001?style=flat-square&logo=rubyonrails&logoColor=white" alt="Rails 6.1+" /></a>
</p>

<p align="center">
  <a href="docs/AGENTS.md"><strong>AGENTS.md</strong></a>
  ·
  <a href="https://rails-agent.com/docs/getting-started">Getting started</a>
  ·
  <a href="https://rails-agent.com/docs/coding-agents">Coding agents</a>
  ·
  <a href="https://cloud.rails-agent.com">Cloud</a>
</p>

---

## About

[Rails Agent](https://rails-agent.com) is a single, beautiful full-stack **agentic platform for Ruby on Rails**. Easily build chatbots, knowledge (RAG-style) agents, workflow agents, operations jobs, monitoring agents, and every agentic workflow you can think of — as files in `app/agents/`, with a mounted `/agents` dashboard and hosted cloud runtime.

**Build** with instructions, tools (function calling), connectors, channels, skills, packages, knowledge, memory, guardrails, playbooks, and a shared library. **Test** in the cloud sandbox with streaming, evals, and traces. **Deploy** with `rails-agents sync` → production harness and BYOK credentials. **Monitor** runs, cost, budgets, and evals in `/agents`.

**BYOK providers:** OpenAI, Anthropic, Google Gemini, OpenRouter, xAI, Groq, Mistral AI, DeepSeek, Together AI, Fireworks AI, Perplexity, Cerebras, Hugging Face, and custom OpenAI-compatible providers. Reference keys as `credential: :company_openai` — secrets never live in Git.

If you are searching for a **Rails AI agents** stack, an **ActiveAgent alternative**, or a **RubyLLM alternative**, Rails Agent is built for the full lifecycle: author in Git, run in the cloud, integrate responses into your product.

**Website:** [rails-agent.com](https://rails-agent.com)

---

## Why Rails Agent (vs RubyLLM & ActiveAgent)

Rails Agent is a better alternative to library-only LLM wrappers when you need agents that ship with your Rails app — not just chat completions.

| | **Rails Agent** | RubyLLM | ActiveAgent |
|--|-----------------|---------|-------------|
| **Scope** | Fullstack agentic platform (build → deploy → monitor) | LLM client / chat helpers | Agent abstractions in Rails |
| **Source of truth** | `app/agents/` directories in your repo | Application code calling the gem | Ruby classes / generators |
| **Dashboard** | Mounted `/agents` (test, deploy, traces, cost) | — | Limited / app-owned |
| **BYOK credentials** | Cloud-managed references (`credential: :company_openai`) | Env / config in app | App-managed |
| **Build surface** | Instructions, tools, connectors, channels, skills, packages, knowledge, memory, guardrails | Prompts + API calls | Tools / prompts (varies) |
| **Playbooks & Library** | Workspace reuse + proven scaffolds | — | — |
| **Channels** | Open-Wire Slack / Teams, web, cron, API | — | App-wired |
| **Ops** | Budget, guardrails, evals, Monitor | Caller responsibility | Caller responsibility |
| **Best for** | Production **Rails AI agents** end-to-end | Thin LLM access | Lightweight agent objects |

Positioning in one line: **most advanced agentic platform for Ruby on Rails** — git-native agents with cloud runtime, integrations, and production controls.

---

## Features

### Build

| Capability | What you get |
|------------|----------------|
| **Instructions** | `prompt.md` system prompt — reviewed in Git |
| **Tools** | Ruby function calling over your ActiveRecord models |
| **Connectors** | OAuth SaaS (Sheets, Notion, HubSpot, …) from the dashboard |
| **Channels** | Slack & Microsoft Teams via **Open-Wire**, web chat, cron, HTTP API |
| **Skills** | Composable multi-step behaviors |
| **Packages** | Install from Skills.sh / Microsoft APM / Smithery |
| **Knowledge** | Docs + database grounding for RAG-style answers |
| **Memory** | Conversation memory (Mem0-backed), on by default |
| **Guardrails** | Model access, prompt injection, sensitive info |
| **Playbooks** | Proven scaffolds you customize locally |
| **Library** | Share tools, skills, packages, knowledge, connectors (`app/agents_library/` + `imports.yml`) |

### Test

| Capability | What you get |
|------------|----------------|
| **Sandbox runs** | Cloud test tab — iterate without production traffic |
| **Streaming** | Token streaming for interactive channels and the dashboard |
| **Evals** | Golden success/failure cases under `evals/` before deploy |
| **Traces** | Tool calls, model turns, and run history while testing |

### Deploy

| Capability | What you get |
|------------|----------------|
| **Sync** | `rails-agents sync` — push `app/agents/` to the cloud |
| **Production deploy** | `rails-agents deploy` — hosted production harness |
| **BYOK** | Attach provider keys in cloud; reference as `credential: :name` |
| **Channels go-live** | Open-Wire Slack/Teams, web, cron, API on the deployed agent |
| **CLI** | `run`, `logs`, and related commands for the agent lifecycle |

### Monitor

| Capability | What you get |
|------------|----------------|
| **Runs & traces** | Every production run, tool call, and model turn |
| **Budget** | Per-agent / policy spend limits |
| **Evals in Monitor** | Keep regression cases visible after ship |
| **Usage & cost** | Observe spend in `/agents` |

### BYOK providers

OpenAI · Anthropic · Google Gemini · OpenRouter · xAI · Groq · Mistral AI · DeepSeek · Together AI · Fireworks AI · Perplexity · Cerebras · Hugging Face · custom OpenAI-compatible providers

### Also

- **Open-Wire** — Slack and Teams channel transport over `open-wire/1`
- **Composio email** — email connectors for inbox workflows
- **Coding-agent docs** — Cursor, Codex, and Claude Code follow [AGENTS.md](docs/AGENTS.md) and [Coding agents](https://rails-agent.com/docs/coding-agents)

---

## Install

```ruby
# Gemfile
gem "rails-agent-stack", "~> 0.2.3"
```

```bash
bundle install
bin/rails generate rails_agents:install
bin/dev   # → http://localhost:3000/agents
```

Connect your company workspace at `/agents`, then scaffold a database Knowledge agent:

```bash
bin/rails generate rails_agents:agent store_assistant --type knowledge --database
```

**Zeitwerk:** fresh installs add `config/initializers/rails_agents_autoload.rb` so `app/agents/` and `app/agents_library/` are agent assets, not application namespaces.

External coding agents (Cursor, Claude Code, Codex): start with **[docs/AGENTS.md](docs/AGENTS.md)**.

---

## Quick start

```bash
bundle exec rails-agents run store_assistant "Where is order ORD-DEMO-1001?"
bundle exec rails-agents sync store_assistant
bundle exec rails-agents deploy store_assistant
bundle exec rails-agents logs store_assistant
```

```ruby
class StoreAssistant < RailsAgents::KnowledgeAgent
  model :gpt_5_mini, provider: :openai, credential: :company_openai
  memory :conversation, provider: :mem0, recall: 5
  knowledge_from "knowledge/**/*"

  tool :lookup_order do |order_number:|
    Order.find_by(number: order_number)&.as_json(only: %i[number status total_cents])
  end
end
```

`:company_openai` is a **cloud credential reference** — not a local env var. Enable managed memory from **Build → Memory**. Pass a stable `session_id` to `.run` so recall stays scoped per product user.

---

## Agent directory

```
app/agents/store_assistant/
├── agent.rb            # RailsAgents::KnowledgeAgent subclass
├── prompt.md           # System prompt
├── imports.yml         # Optional workspace Library attachments
├── tools/              # Optional extracted tools
├── skills/             # Composable behaviors
├── packages/           # Registry-installed capabilities
├── memory.rb           # Memory config
├── knowledge/          # RAG files
├── connectors/         # External connection manifests
├── channels/           # Slack, Teams, web, API, …
└── evals/              # Smoke / regression cases

app/agents_library/
├── tools/
├── skills/
├── packages/
├── knowledge/
└── connectors/
```

Keep one-off work inside the agent. Move stable capabilities to `app/agents_library/` when another agent should reuse them, then reference via `imports.yml`. `rails-agents sync` includes imported Library files in the runtime bundle without duplicating shared source in Git.

---

## Agent taxonomy

| Type | Main purpose | Example |
|------|--------------|---------|
| Knowledge | Understand and answer | Order support from Rails data |
| Workflow | Execute predictable processes | Refund approval |
| Operations | Coordinate unpredictable real-world work | Incident coordination |
| Monitoring | Observe changes and respond | Inventory watcher |

Generator: `--type knowledge|workflow|operations|monitoring` and `--database` for DB-connected Knowledge scaffolds.

**Integrate responses:** every run returns `output_text` (Markdown), optional `output_data`, and typed `items` — same shape for every LLM. Guide: [rails-agent.com/docs/run-response](https://rails-agent.com/docs/run-response).

---

## Configuration

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]       # platform key
  config.project_id = ENV["RAILS_AGENTS_PROJECT_ID"]
end
```

Provider keys live in the cloud dashboard → Model credentials (BYOK). Never commit them.

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

Local path testing: sibling app `rails-agents-boilerplate`.

---

## License

MIT — [MIT-LICENSE](MIT-LICENSE)

[rails-agent.com](https://rails-agent.com) · [AGENTS.md](docs/AGENTS.md) · [Getting started](https://rails-agent.com/docs/getting-started)
