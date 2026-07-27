# Rails Agent — Product Requirements Document

> **`rails-agent-stack` gem** (OSS, mounts into Rails) + **Rails Agent Cloud** (managed backend). Build agents locally with docs and external coding agents; test, deploy, and monitor at `/agents`.

## 1. Mission

Make Rails Agent the **fullstack agentic platform for Rails**: developers scaffold agents in `app/agents/`, attach **BYOK** model credentials in the cloud, and use `/agents` to test, deploy, and monitor — with clear docs (**AGENTS.md**) for humans and external coding agents.

## 2. Core Philosophy

1. **Documentation-first** — AGENTS.md progressive path; no chat-based authoring.
2. **Build in the repo** — Ruby agent directories, generators, external coding agents.
3. **BYOK models** — provider credentials stored encrypted in cloud; referenced from agent DSL.
4. **Four taxonomy types** — Knowledge, Workflow, Operations, Monitoring.
5. **Test → deploy → monitor in one place** — `/agents` dashboard embed.
6. **Transparent company billing** — fixed subscription + pass-through usage + 1% service fee.

## 3. Product Surface

### 3.1 `rails-agent-stack` gem

- Install: `bundle add rails-agent-stack` + `rails generate rails_agents:install`.
- Mountable engine at `/agents`: signup, connect, dashboard embed, **schema bridge** for DB setup.
- Agent-as-directory under `app/agents/<name>/`.
- **Product-facing taxonomy classes**: `KnowledgeAgent`, `WorkflowAgent`, `OperationsAgent`, `MonitoringAgent`.
- **DSL**:

```ruby
class StoreAssistant < RailsAgents::KnowledgeAgent
  model :gpt_5_mini, provider: :openai, credential: :company_openai
  memory :conversation
  knowledge_from "knowledge/**/*"

  tool :lookup_order do |order_number:|
    Order.find_by(number: order_number).as_json
  end

  channel :web
end
```

- **CLI**: install, new, run, sync, deploy, logs, traces, evals. `pull` deprecated.
- **Generator**: `--type`, `--database` for first database Knowledge agent.
- Runtime: thin client to cloud for inference, deploys, observability. Tools execute in Rails app context.

### 3.2 Rails Agent Cloud

- Auth, workspaces (company-scoped), API keys.
- **Credential vault** for BYOK (OpenAI, Anthropic, etc.) — referenced by symbol from agents.
- Model gateway resolves agent model + credential ref.
- Deploys, channels, vector/RAG, evals, traces, billing.
- **Billing**: Stripe company subscription + metered usage at cost + 1% service fee.
- API: runs, deploys, knowledge sync, files sync, logs, traces, evals.

### 3.3 Dashboard

- Workspace: agents list, config (model/credential, tools, skills, memory, knowledge, channels, evals, deploy).
- **No Kip / chat authoring** — configuration and monitoring UI only.
- Schema discovery via parent page `GET /agents/schema`.

## 4. Pricing

- **Company subscription** — fixed monthly fee per workspace (production).
- **Metered usage** — provider tokens and infrastructure at **pass-through cost**.
- **Service fee** — **1%** on metered usage, shown transparently on invoices.
- Sandbox/dev tier for building (non-production traffic).

## 5. Non-Goals

- Chat-based agent authoring (removed).
- Storing provider API keys in the Rails app repo.
- Self-hosting / on-prem (cloud runtime).
- Non-Rails frameworks.

## 6. Milestones

1. **M1 — Gem + docs**: install, AGENTS.md, taxonomy, BYOK DSL, `--database` generator.
2. **M2 — Cloud BYOK + billing**: credential vault, company plans, usage metering + 1%.
3. **M3 — Channels + deploy**: Slack, web, API, cron end-to-end.
4. **M4 — GA**: evals, monitoring agents, plugins/skills/playbooks in dashboard.

## 7. SEO / Brand

- Name: **Rails Agent** / `rails-agent-stack`.
- Tone: confident, plainspoken, Rails-native.

---

**Instruction to implementers**: Gem and boilerplate follow this doc. Cloud dashboard must remove authoring chat and implement BYOK + company billing.
