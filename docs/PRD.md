# Rails Agent — Product Requirements Document

> Build brief for Cursor. Two artifacts: **`rails-agent-stack` gem** (open source, mounts into a Rails app) and **Rails Agent Cloud** (managed backend running on our Vercel account). This marketing site + dashboard already exists in this repo as the reference UX.

## 1. Mission

Make AI agent development a **zero-knowledge task for Rails developers**. Rails developers add one gem, run one command, and get a mountable `/agents` engine with signup, dashboard, chat-based agent authoring, hosted runtime, monitoring, and one-click channel deploys — with **no AI knowledge, no infra, no API keys**.

## 2. Core Philosophy

1. **Zero AI knowledge** — no prompt engineering, no vector DB choice, no model routing.
2. **Zero config** — models, embeddings, queues, storage, secrets all managed by the cloud.
3. **Vibe coding** — developer chats with Kip (our agent builder); Ruby files are generated in `app/agents/<name>/`.
4. **Build → deploy → monitor in one place** — chat, test, logs, traces, cost, deploy.
5. **Scalable agentic infra** — Sidekiq-like ergonomics, cloud-backed autoscaling.
6. **Unified monitoring & debugging** — every run, tool call, token, and error in one dashboard.

## 3. Product Surface

### 3.1 `rails-agent-stack` gem (OSS)

- Install: `bundle add rails-agent-stack` + `rails agent install`.
- Ships a **mountable Rails Engine** at `/agents` (Sidekiq-style): signup, sign-in, dashboard proxy.
- Generator scaffolds `app/agents/` with the **agent-as-directory** convention (mirrors Eve):

```
app/agents/support/
├── agent.rb            # RailsAgent::Base subclass — entrypoint
├── prompt.md           # system prompt
├── tools/              # tool definitions (Ruby methods with a DSL)
├── skills/             # composable multi-step behaviors
├── memory.rb           # memory config (managed vector store)
├── knowledge/          # files/URLs synced to cloud RAG
├── channels/           # slack.rb, discord.rb, web.rb, etc.
└── evals/              # eval cases + expected outcomes
```

- **DSL example** (`app/agents/support/agent.rb`):

```ruby
class Support < RailsAgent::Base
  model :auto            # cloud-routed; no BYOK
  memory :conversation   # managed
  knowledge_from "knowledge/**/*"

  tool :lookup_order do |order_id:|
    Order.find(order_id).as_json
  end

  skill :triage, from: "skills/triage.rb"
  channel :slack
end
```

- **CLI** (Thor):
  - `rails agent install` — mounts engine, writes initializer, links cloud project.
  - `rails agent new <name>` — scaffolds an agent directory.
  - `rails agent run <name>` — runs an agent locally against the cloud runtime.
  - `rails agent deploy` — pushes agent bundle to cloud.
  - `rails agent logs / traces / evals`.
- **Runtime**: gem is a thin client. All model calls, embeddings, tool sandboxing, vector store, queue and long-running conversations happen in **Rails Agent Cloud** over signed HTTPS/WebSocket. No user-managed API keys.
- **Auth**: Engine login redirects to cloud OAuth; JWT stored per-Rails-app, scoped to a workspace.
- **Dev experience**: `bin/dev` streams logs from cloud into the terminal. File changes in `app/agents/**` hot-sync during dev.

### 3.2 Rails Agent Cloud (managed backend)

- Deployed on **our Vercel account** (Node/Edge functions + Postgres + object store + vector store + queue). Users never see Vercel.
- Services:
  - **Auth**: GitHub OAuth, email link, workspaces, roles.
  - **Project registry**: one project per Rails app; API keys are cloud-issued.
  - **Agent orchestrator**: executes runs, tool calls, streaming, memory, RAG retrieval.
  - **Model gateway**: routes to OpenAI / Anthropic / open models. **We** hold provider keys.
  - **Vector store**: managed embeddings + retrieval per knowledge folder.
  - **Deploys**: bundle Ruby agent directory → containerized runtime → live endpoint per agent per channel.
  - **Channels**: connectors for Slack, Discord, Web Chat (Chat SDK), Google Chat, Teams, WhatsApp, API, Cron, Twilio, Linear, GitHub, Telegram. One-click OAuth from dashboard.
  - **Observability**: runs, traces, token/$ cost, error inspector ("Ask Kip to fix").
  - **Evals**: run stored eval sets on every deploy.
  - **Billing**: Stripe. Free dev sandbox; Studio $49/dev/mo; Enterprise custom.
- **API surface** (HTTP + WS) used by gem:
  - `POST /v1/runs` — start an agent run.
  - `GET  /v1/runs/:id/stream` — SSE tokens/tool events.
  - `POST /v1/deploys` — upload agent bundle (tar of `app/agents/<name>`).
  - `POST /v1/channels/:kind/install` — OAuth install.
  - `POST /v1/knowledge/sync` — index knowledge files.
  - `GET  /v1/logs`, `/v1/traces`, `/v1/evals`.

### 3.3 Dashboard (this repo)

- Public marketing site at `/` (+ SEO landing pages already implemented).
- Auth at `/signin`, `/signup`.
- Workspace at `/dashboard` — agents list, agent detail (chat + config tabs: Model, Tools, Skills, Memory, Knowledge, Prompt, Channels, Evals, Deploy), runs, deployments, settings.
- Agent detail chat is the **primary authoring UI**; it writes files back into `app/agents/<name>/` in the linked repo.

## 4. Pricing

- **Developer** — Free. Sandbox only, non-production.
- **Studio** — $49 / developer / month. Production deploys, all channels, monitoring, evals.
- **Enterprise** — Custom. SSO, dedicated support, VPC-style isolation on our infra.

Margin sits on top of cloud costs (Vercel + provider tokens). All inference is inference-included at Studio tier up to fair-use caps.

## 5. Success Metrics (first 90 days)

- Time from `bundle add` to first live agent < **10 minutes**.
- Dashboard MAU / installs > 40%.
- >70% of created agents deployed to at least one channel.
- SEO: rank top 5 for "rails ai agent", "ruby ai agent framework", "rails llm gem".

## 6. Non-Goals (MVP)

- Self-hosting / on-prem. Cloud only.
- BYOK for model providers.
- Non-Rails frameworks.
- User-managed database migrations for agent state.

## 7. Milestones

1. **M1 — Gem skeleton**: install command, engine mount, generator, cloud auth handshake.
2. **M2 — Agent DSL + run**: `RailsAgent::Base`, tools, prompt, single run via cloud gateway.
3. **M3 — Dashboard authoring**: chat writes files, config tabs persist, test runner.
4. **M4 — Channels**: Slack + Web Chat + API + Cron end-to-end.
5. **M5 — Deploy + monitor**: bundle upload, live endpoint, logs/traces/cost, evals.
6. **M6 — Billing + GA**: Stripe, quotas, docs, launch.

## 8. Repo Layout (target)

```
rails-agent-stack/           # gem
├── lib/rails_agent/
│   ├── base.rb              # DSL
│   ├── engine.rb            # mounts /agents
│   ├── cli.rb               # thor commands
│   ├── client.rb            # cloud HTTP/WS client
│   ├── generators/
│   └── channels/
├── app/                     # engine controllers/views (thin — proxy to cloud)
└── spec/

rails-agent-cloud/           # backend (Vercel monorepo)
├── apps/api/                # HTTP/WS
├── apps/dashboard/          # THIS repo — TanStack Start UI
├── services/orchestrator/
├── services/model-gateway/
├── services/vector/
├── services/deploys/
└── packages/shared/
```

## 9. Design + Brand

- Name: **Rails Agent** (product) / `rails-agent-stack` (gem).
- Mascot: **Kip**, the meerkat.
- Palette: ruby `#B4182D`, cream `#FBF7F0`, ink `#0F0F10`, ember accent.
- Type: Fraunces (display) + Inter (body) + JetBrains Mono (code).
- Tone: confident, plainspoken, Rails-native. Never marketing-jargon.

## 10. SEO / AEO

- `sitemap.xml` generated dynamically with self-referencing origin.
- `robots.txt` allows GPTBot, ClaudeBot, PerplexityBot, Google-Extended, etc.
- Every route has unique `title`, `description`, `og:*`, canonical.
- JSON-LD: Organization + WebSite + SoftwareApplication on root; Article on guides; FAQ on comparisons.
- Landing page clusters: `/compare/*`, `/use-cases/*`, `/solutions/*`, `/guides/*`, `/channels/*` — all interlinked in footer.

---

**Instruction to Cursor**: Build `rails-agent-stack` gem and `rails-agent-cloud` backend to satisfy sections 3.1 and 3.2. Use this dashboard repo verbatim for the UI. Do not introduce BYOK, self-hosting, or non-Rails targets in MVP.
