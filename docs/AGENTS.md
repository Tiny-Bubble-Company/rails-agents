# AGENTS.md — Rails Agent onboarding

Guide for **external coding agents** (Cursor, Claude Code, Codex, etc.) and humans building on Rails Agent.

## What this platform is

Rails Agent is a **fullstack agent platform for Rails**: you write agents as Ruby directories under `app/agents/`, connect provider credentials (BYOK) in the cloud dashboard, then **test, deploy, and monitor** at `/agents`.

Billing: **fixed company subscription** + **metered usage at provider/infrastructure cost** + **transparent 1% service fee**.

## Agent taxonomy (pick one)

| Type | Main purpose | Example |
|------|--------------|---------|
| **Knowledge** | Understand and answer | Order support from Rails data and policy docs |
| **Workflow** | Execute predictable processes | Verify → approve → refund → notify |
| **Operations** | Coordinate unpredictable real-world work | Incident or customer escalation coordination |
| **Monitoring** | Observe changes and respond | Inventory, error, or SLA watcher |

Use the matching base class: `RailsAgents::KnowledgeAgent`,
`WorkflowAgent`, `OperationsAgent`, or `MonitoringAgent`.

Legacy aliases (deprecated): `ChatAgent` → Knowledge, `BackgroundAgent` → Operations.

## Run response schema (integrate into product)

Every provider (OpenAI, Anthropic, Gateway, OSS) normalizes to one shape.
Your app should not branch on provider-specific payloads.

| Field | Use |
|-------|-----|
| `result.output_text` | Final Markdown answer for chat / email / Slack |
| `result.output` | Legacy alias for `output_text` |
| `result.output_data` | Optional structured Hash for Rails branching (`nil` if text-only) |
| `result.items` | Typed turn: `message` (+ `result` when `output_data` present) |
| `result.format` | Always `"markdown"` for message content |
| `result.trace` | Tools / debug — Monitor, not the product answer |

```ruby
result = StoreAssistant.run("Where is ORD-1001?", session_id: "user-1")
puts result.output_text
payload = result.output_data  # Hash or nil
```

Consumption by taxonomy:

- **Knowledge** — render Markdown (`output_text`); tables for catalogs
- **Workflow** — show `output_text`; branch on `output_data` (status, ids)
- **Operations** — post `output_text`; handoff via `output_data`
- **Monitoring** — alert with `output_text`; automate from `output_data`

Public docs: https://rails-agent.com/docs/run-response

## Progressive path

### 1. Connect workspace

```bash
bundle add rails-agent-stack
bin/rails generate rails_agents:install
bin/dev   # open http://localhost:3000/agents
```

Sign up / connect at `/agents`. Platform API key is written to `config/rails_agents_credentials.yml` — **not** your OpenAI/Anthropic keys.

### 2. First agent: database Knowledge (fastest win)

```bash
bin/rails generate rails_agents:agent store_assistant --type knowledge --database
bin/rails db:seed   # if demo data exists
```

Edit `app/agents/store_assistant/agent.rb` — tools call your ActiveRecord models. Attach BYOK in cloud dashboard → **Settings → Providers** (reference name e.g. `:company_openai`).

```ruby
class StoreAssistant < RailsAgents::KnowledgeAgent
  model :gpt_5_mini, provider: :openai, credential: :company_openai
  memory :conversation, provider: :mem0, recall: 5

  tool :lookup_order do |order_number:|
    # wire to your models
  end
end
```

Test locally:

```bash
bundle exec rails-agents run store_assistant "Where is order ORD-DEMO-1001?"
bundle exec rails-agents sync store_assistant
```

Dashboard uses `GET /agents/schema` to discover tables for database setup — keep that endpoint available.

### 3. Tools

Add Ruby tool blocks in `agent.rb` or files under `tools/`. Tools run in your Rails app context.
Start with one read-only tool and test it before adding side effects.

### Workspace Library (share only when reuse is real)

Agent-specific capabilities stay under `app/agents/<slug>/`. Capabilities used
by multiple agents have one canonical source under:

```text
app/agents_library/
├── tools/
├── skills/
├── packages/
├── knowledge/
└── connectors/
```

Attach shared sources through `app/agents/<slug>/imports.yml`:

```yaml
version: 1
imports:
  - kind: skill
    slug: triage
    from: library/skills/triage.rb
  - kind: knowledge
    slug: shipping_policy
    from: library/knowledge/shipping_policy.md
  - kind: package
    slug: frontend_design
    from: library/packages/frontend_design
```

`bundle exec rails-agents sync NAME` safely resolves these paths and includes
them in the agent bundle. It fails on path traversal, missing sources, or a
conflict with an agent-local file. This keeps the Library canonical without
duplicating generated copies in Git.

Shared Ruby tool files are organization boundaries, not a new DSL. Register the
tool in `agent.rb` using the normal `tool` block and call the shared module or
service from that block.

### 4. Connectors

Add external SaaS integrations via Connect in the cloud dashboard (OAuth-managed actions). Use a local Ruby tool for your own database; use a connector for systems such as Notion, Sheets, or HubSpot.

### 5. Skills

Composable behaviors in `skills/` — reference with `skill :name, from: "skills/name.rb"`.

### 5b. Packages (agentic package manager)

**Package** is the installable primitive. Search Skills.sh, Microsoft APM, and
Smithery from the dashboard (**Library → Packages** or agent **Build → Packages**),
or via CLI:

```bash
bundle exec rails-agents packages "refund"
bundle exec rails-agents add-package skills_sh:owner/repo/skill \
  --registry skills_sh --agent store_assistant --source owner/repo
```

Rails Agent downloads the upstream package, converts it into:

```text
app/agents/<slug>/packages/<name>/package.yml
app/agents/<slug>/packages/<name>/SKILL.md
app/agents/<slug>/skills/<name>.rb      # capability ready immediately
```

and can save it to the workspace Library like tools/skills/plugins.

| Primitive | Meaning |
|-----------|---------|
| **Tool** | One deterministic Ruby action |
| **Skill** | Multi-step playbook (how to do work) |
| **Package** | Installable capability from external registries |
| **Connector** | External SaaS (OAuth Connect) |
| **Knowledge** | Docs / DB sources for grounding |
| **Library** | Workspace reuse of any of the above |

### 6. Playbooks

Clone a Playbook when you want a proven starting structure, then customize the generated files locally. Playbooks can combine instructions, tools, and skills.

### 7. Channels

Scaffold stubs live in `channels/`. Install connectors from `/agents` dashboard (Slack, web chat, API, cron, etc.).

### 8. Evals

Add cases under `evals/*.yml`. Run on deploy from dashboard or `bundle exec rails-agents evals NAME`.

### 9. Deploy & monitor

```bash
bundle exec rails-agents deploy store_assistant
bundle exec rails-agents logs store_assistant
bundle exec rails-agents traces store_assistant
```

Use `/agents` for runs, cost, traces, and eval results.

## Model DSL (BYOK)

```ruby
# Explicit provider + cloud credential reference (no secrets in repo)
model :gpt_5_mini, provider: :openai, credential: :company_openai

# Legacy cloud-routed (still supported, not default in new scaffolds)
model :auto
```

Credential symbols map to encrypted records in Rails Agent Cloud — never commit API keys.

## Do not use (deprecated)

- **Chat authoring / cloud pull** — build locally; push with `rails-agents sync`. CLI `pull` remains for compatibility only.

## References

- Gem README: [README.md](README.md)
- Product spec: [docs/PRD.md](docs/PRD.md)
- Website: https://rails-agent.com/docs/getting-started
