# Rails Agents v2 — Architecture North Star

**Status:** Draft for rebuild  
**Date:** 2026-07-15  
**Inspiration studied:** [vercel/eve](https://github.com/vercel/eve) (local clone + eve.dev docs)  
**Product thesis:** World’s simplest Rails agentic DX — Eve-grade power underneath, near-zero config for developers, cloud-by-default, cash + usage visibility for Tiny Bubble Company.

---

## 1. What Eve actually is (after full study)

Eve is **not** “a chat SDK.” It is a **filesystem-first durable agent runtime**:

| Layer | What it does |
|-------|----------------|
| **Authoring** | Capabilities live as files under `agent/` — `instructions.md`, `agent.ts`, `tools/`, `skills/`, `channels/`, `connections/`, `sandbox/`, `subagents/`, `schedules/`, `hooks/` |
| **Discover → Compile** | Walk filesystem → `.eve/` manifests (no manual registries; path = identity) |
| **Harness** | Model tool-loop (AI SDK), default tools (bash/files/web/todo/ask_question/agent/…) |
| **Durability** | Session → turn → step via **Workflow SDK**; park/resume for HITL, OAuth, subagents |
| **Sandbox** | Isolated `/workspace` for code/files; app tools keep `process.env` secrets |
| **Channels** | Same agent over HTTP, Slack, Discord, cron, web UI |
| **Evals** | `evals/` sibling of `agent/`; `eve eval` against local or deployed URL |
| **CLI lifecycle** | `init` → `dev` → `eval` → `build` → `deploy` / `start` |
| **Vercel path** | AI Gateway + Vercel Workflow + Vercel Sandbox + Cron + Connect + Agent Runs dashboard |

**Mental model Eve teaches:** files are the interface; one portable agent loop for every surface; durable by default; grow by adding folders.

**Critical implication for us:** Reimplementing Workflow + Sandbox + Channels in pure Ruby would take years and throw away the infra we want to monetize. **v2 inherits Eve’s runtime by compiling a Ruby DSL onto Eve projects hosted on our central Vercel org.**

---

## 2. Product repositioning (philosophy preserved)

### Old (v0.1)

> No dashboards, no cloud accounts — gem-only, BYOK providers.

### New (v2)

> **Cloud by default. Zero infra for Rails developers.**  
> Author agents in Ruby. We run durable sessions, sandboxes, logs, evals, and promote sandbox → production.  
> Still the **smallest mental model** in Rails: one agent folder, tools as Ruby, `.run` / `.stream`.

We still compete on **simplicity + speed to production**. Power comes from Eve/Vercel underneath; developers never see Node, Workflow worlds, or sandbox backends unless they opt into advanced self-host later.

---

## 3. Target developer journey (hyper-simple)

```text
1. Sign up          → full name, email, company, website (free)
2. Create app/key   → sandbox key issued (runs blocked until funded)
3. rails g …        → app/agents/<name>/ + Tool Bridge mount
4. Define agent     → Ruby + tools
5. Add Credits      → min $10 prepaid (or enable BYOK for sandbox)
6. .run / playground → hosted Eve on our Vercel tenancy
7. Dashboard        → logs, traces, evals
8. Subscribe        → promote → rak_live_… production
```

**Lines of code to first hosted agent:** initializer + one agent + one tool + Credits top-up. No customer Vercel/Eve account.

---

## 4. System architecture

```text
┌──────────────────────────────────────────────────────────────────────────┐
│                         Customer Rails App                               │
│  app/agents/lead_qualifier/{agent.rb,instructions.md,tools/*.rb,…}       │
│  gem: rails-agent-stack                                                  │
│    • Ruby DSL (Eve semantics, Rails-native)                              │
│    • Sync/compile client → Cloud API                                     │
│    • Session SDK (.run / .stream / .continue)                            │
│    • Tool Bridge (HTTP webhook: cloud calls back into Rails tools)       │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │ HTTPS (tenant API key)
                                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                    Tiny Bubble Control Plane                             │
│  • Auth / orgs / apps / environments (sandbox | production)              │
│  • API keys, audit log, usage metering                                   │
│  • Dashboard: agents, runs, traces, evals, promote, billing              │
│  • Stripe: commission on top of Vercel + model usage                     │
│  • Multi-tenant router → per-tenant Eve deployment                       │
└───────────────────────────────┬──────────────────────────────────────────┘
                                │ provision / deploy / proxy
                                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│              Central Vercel Team (Tiny Bubble Company)                   │
│  Per tenant × env: Eve project (or namespaced multi-service)             │
│    Vercel Workflow · Vercel Sandbox · AI Gateway · Cron · Connect        │
│  Tenant isolation: project boundaries + auth stamps + secret scopes      │
└──────────────────────────────────────────────────────────────────────────┘
```

### Why this wins

| Goal | How |
|------|-----|
| Visibility into use cases | Every signup, agent, run, eval goes through our control plane |
| Revenue | Stripe subscription / usage markup on Gateway + Sandbox + Workflow |
| Simplest DX | Hide Eve/Vercel complexity; Ruby + dashboard only |
| Most powerful | Full Eve durability, sandbox, channels, HITL, evals, schedules |
| Rails-native | Tools stay ActiveRecord/services via Tool Bridge |

---

## 5. Eve → Rails Agents concept map

| Eve | Rails Agents v2 | Notes |
|-----|-----------------|-------|
| `agent/instructions.md` | `app/agents/<id>/instructions.md` or `description` in `agent.rb` | Markdown preferred for parity |
| `agent/agent.ts` + `defineAgent` | `app/agents/<id>/agent.rb` | `model`, limits, output schema |
| `agent/tools/*.ts` + `defineTool` | `app/agents/<id>/tools/*.rb` | Path = tool name; Zod → dry-validation / params DSL |
| `agent/skills/*.md` | `app/agents/<id>/skills/*.md` | Same on-demand skill model |
| `agent/channels/` | Cloud-managed first; optional `channels/` later | Default = our HTTP channel |
| `agent/connections/` | Dashboard “Connections” + Ruby stubs | OAuth via our Connect proxy |
| `agent/sandbox/` | Always on in cloud; no customer config | We choose `vercel()` backend |
| `agent/subagents/<id>/` | `app/agents/<id>/subagents/<child>/` | Nested folders |
| `agent/schedules/` | `app/agents/<id>/schedules/*.rb` or dashboard cron | Compiles to Eve schedules |
| `agent/hooks/` | Phase 2 | Observe-only lifecycle |
| `evals/` | `test/agents/**/*.eval.rb` or dashboard suites | Cloud runner |
| `eve init/dev/eval/build/deploy` | Signup + `rails g` + dashboard Promote | No Node required |
| `useEveAgent` / HTTP session API | `RailsAgents::Session` + Hotwire/React helpers | Same session/stream contract |
| Session / turn / step | Same vocabulary in docs & dashboard | Educate Rails devs on durability |
| Park / HITL | `approval` on tools + dashboard / chat UI | Resume via continuation token |
| Multi-tenant patterns | **Productized** (Eve only documents patterns) | Our differentiator |

---

## 6. Ruby DSL (simplified Eve)

Target authoring surface — **one agent = one folder**:

```text
app/agents/
  lead_qualifier/
    agent.rb
    instructions.md
    tools/
      search_crm.rb
      create_crm_note.rb
    skills/
      enterprise_signals.md
    subagents/
      researcher/
        agent.rb
        instructions.md
        tools/
          fetch_url.rb
```

```ruby
# app/agents/lead_qualifier/agent.rb
class LeadQualifier < RailsAgents::Agent
  model "anthropic/claude-sonnet-5"   # gateway id; we meter it
  # tools/skills auto-discovered from sibling folders
end
```

```ruby
# app/agents/lead_qualifier/tools/search_crm.rb
class SearchCrm < RailsAgents::Tool
  description "Search CRM companies"
  param :query, :string

  def call(query:)
    Company.search(query).limit(5).as_json(only: %i[id name plan])
  end
end
```

```ruby
# app/controllers/... or job
result = LeadQualifier.run("New signup from acme.com")
# or
session = LeadQualifier.session.create(message: "...")
session.stream { |event| ... }
session.continue("Now check Queens")
```

### Tool Bridge (Rails stays source of truth for app data)

1. Developer defines tool in Ruby (runs in **their** Rails app).
2. On sync, cloud registers a **proxy tool** on the Eve agent with the same name/schema.
3. When the model calls the tool, Eve hits our control plane → signed webhook to the tenant’s Rails app → tool `call` → result returned to the model.
4. Sandbox/default harness tools (bash, files) stay on Vercel Sandbox — never see Rails secrets.
5. Optional: mark a tool `runtime: :sandbox` only if we later support generated JS/Python in sandbox (advanced).

This keeps **Rails models/jobs in Rails**, and **durable agent loop + sandbox on Eve**.

---

## 7. Control plane + dashboard (Agno-like × Eve lifecycle)

### Dashboard modules (MVP → v1)

| Module | Purpose |
|--------|---------|
| **Apps** | Create app; Sandbox vs Production |
| **Agents** | Synced agent tree; instructions preview |
| **Playground** | Chat with sandbox/production agent |
| **Runs / Traces** | Session → turn → step tree (tokens, latency, tool I/O) |
| **Evals** | Suites, scores, CI webhook |
| **Logs / Debug** | Stream events, park/HITL state |
| **Keys** | Sandbox & Production API keys |
| **Billing** | Stripe; usage; promote to production |
| **Settings** | Company profile, webhook URL for Tool Bridge |

### Environment model

| Env | Behavior |
|-----|----------|
| **Sandbox** | Free/limited credits; auto on signup; isolated Eve project |
| **Production** | Requires Stripe; separate Eve project + keys; promote copies agent bundle |

Promote is **not** “rewrite infra” — it is “deploy same compiled agent definition to Production Eve project + flip default endpoint.”

---

## 8. Multi-tenancy — one Vercel project, logical isolation

**Locked:** All tenants share **one** Tiny Bubble Vercel project (Eve + Workflow + Sandbox + Gateway). Isolation is logical — `tenant_id` + `environment` (`sandbox` \| `production`) — like serverless account separation on shared infra.

Full model: [TENANCY.md](./TENANCY.md).

Summary:

1. API key → `{ tenant_id, app_id, environment }`.
2. Agent artifacts versioned under that composite key (not separate Vercel projects).
3. Sessions/traces/quotas/secrets always scoped by tenant+env.
4. Tool Bridge webhooks only to that app’s Rails URL.
5. Customers never see Vercel — only our Next.js dashboard.

---

## 9. Monetization (bootstrap — $0 CAC)

Full model: [PRICING.md](./PRICING.md).

| Lever | Mechanism |
|-------|-----------|
| Free | Signup + define agents + dashboard (**no hosted LLM/sandbox spend**) |
| Optional $0 test | **BYOK** in sandbox (customer’s provider key) |
| Paywall | **Min $10 Credits** before any hosted `.run`; production needs subscribe |
| Usage | 1-1 Vercel meters (Gateway, Sandbox, Fluid) × **(1 + margin)** — prepaid only |
| Platform | Small monthly fee when enabling production |
| Growth | **gem installs → funded accounts → usage margin** |

Tiny Bubble never fronts token/sandbox cost. Vercel’s team free credit is ops buffer only.

---

## 10. Repo / product split (mirror Eve’s monorepo spirit)

Proposed layout under Tiny Bubble (can start as monorepo or sibling repos):

```text
rails-agents/                  # open-source gem + DSL + Tool Bridge
  lib/rails_agents/            # authoring + client SDK
  docs/                        # DX docs (VitePress)

rails-agents-cloud/            # private control plane (Rails or Next)
  apps/web/                    # dashboard
  apps/api/                    # signup, keys, sync, billing, proxy
  packages/compiler/           # Ruby agent tree → Eve agent/ filesystem
  packages/provisioner/        # Vercel project create/deploy APIs

eve/                           # vendor reference (already cloned) — do not fork lightly
```

Open-source gem stays MIT and beautiful. Cloud is the business.

---

## 11. Phased rebuild plan

### Phase 0 — Spec freeze (this doc)
- Align on architecture (compile-to-Eve, not reimplement Workflow in Ruby)
- Name: keep **Rails Agents** / gem `rails-agent-stack`

### Phase 1 — Ruby authoring + compile (OSS)
- New folder layout under `app/agents/<id>/`
- Compiler: Ruby/MD → Eve `agent/` tree (TypeScript tool shims that call Tool Bridge)
- Local mode optional: keep v0.1 in-process runner for offline demos OR deprecate

### Phase 2 — Control plane MVP (private)
- Signup, apps, sandbox provision (manual ops OK at first)
- API keys, session proxy to Eve deployment
- Tool Bridge webhook protocol + Rails engine middleware
- Minimal dashboard: playground + run list

### Phase 3 — Agno-grade dashboard
- Traces (session/turn/step), evals UI, logs, HITL approvals
- Sandbox → Production promote + Stripe Checkout

### Phase 4 — Channels & connections
- Slack/etc via our Connect proxy
- Schedules from Ruby or dashboard

### Phase 5 — Scale tenancy
- Automated Vercel project provisioning
- Quotas, abuse controls, SSO

---

## 12. Compatibility with v0.1 gem

**Locked: cloud-only.** The supported product path is Cloud API + Tool Bridge.

```ruby
RailsAgents.configure do |config|
  config.api_key = ENV["RAILS_AGENTS_API_KEY"]           # rak_sandbox_… or rak_live_…
  config.api_base = ENV.fetch("RAILS_AGENTS_API_BASE", "https://api.railsagents.dev")
  config.tool_bridge_secret = ENV["RAILS_AGENTS_BRIDGE_SECRET"]
end
```

In-process BYOK provider loops from v0.1 are **not** a supported product mode (may remain briefly as private test doubles). Docs and generator ship cloud-only.

Docs site remains on **GitHub Pages**. Dashboard/API host on the shared Vercel project.

Decisions log: [DECISIONS.md](./DECISIONS.md).

---

## 13. Explicit non-goals (keeps us simple)

- Rebuilding Workflow SDK in Ruby
- Forcing customers to own Vercel/Eve accounts
- One Vercel project per tenant
- Exposing TypeScript `defineTool` to Rails developers
- Feature parity with Eve’s every channel on day one
- Supported local BYOK runtime

---

## 14. Build sequence (in progress)

1. ~~Lock decisions~~ → [DECISIONS.md](./DECISIONS.md) + [TENANCY.md](./TENANCY.md)
2. Cloud-only gem client + Tool Bridge mount
3. Next.js control plane scaffold (`cloud/`)
4. Compiler spike: one agent → Eve artifact on shared project
5. Dashboard: signup, keys, playground, promote + Stripe
