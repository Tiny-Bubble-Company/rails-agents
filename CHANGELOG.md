# Changelog

All notable changes to this project are documented in this file.

## [0.2.0.pre] — 2026-07-16

Cloud-only rebuild (pre-release).

- Messaging: durable / Eve-shaped directory DX; clearer vs RubyLLM (agents vs toolkit)

- **Breaking:** `.run` calls Rails Agents Cloud (requires `RAILS_AGENTS_API_KEY`)
- Tool Bridge endpoint + HMAC signature helpers
- Installer mounts `RailsAgents::Engine` at `/agents` (Sidekiq-style Web UI + Tool Bridge at `/agents/bridge`)
- **Web UI:** `/agents` signup → Cloud session → agents list, credits, deep links to full dashboard
- Architecture: compile-to-Eve, one Vercel project with logical tenancy (`sandbox` \| `production`)
- Billing: **prepaid Credits** (min $10) before hosted runs; free = build only; optional BYOK; `PaymentRequired` on 402
- **Directory DX (Eve-shaped):** `app/agents/<name>/instructions.md` + `RailsAgents["name"].run(…)` (syncs then runs)
- **CLI:** `rails-agents new | test | deploy | status` (weather brief reference scaffold + schedule)
- Generator: `rails generate rails_agents:agent NAME` (instructions + `schedules/morning.yml`)
- Cloud portal: agents list, detail runs/logs, subscribe + deploy gate
- Host: Hetzner beside Meerkat (`agents.meerkatagents.com`)

## [0.1.0] — 2026-07-09

First public release. Published on RubyGems as **`rails-agent-stack`** (Ruby API remains `RailsAgents`).

- `RailsAgents::Agent` — one class for every use case (`provider`, `model`, `description`, `tools`, `skills`)
- `RailsAgents::Tool` — app code as tools, auto-loaded from `app/agents/tools/`
- Skills: `:web_search`, `:web_fetch` (portable + Anthropic native); Anthropic `:code_execution`, `:memory`, `:pptx`, `:xlsx`, `:docx`, `:pdf`
- Providers: OpenAI, Anthropic, OpenRouter, Grok
- Install generator (`rails generate rails_agents:install`)
- Sample playground app in `spec/dummy/`
- Documentation site (VitePress) on GitHub Pages
- Fix: `Providers.build` no longer passes a nil API key that overrode config defaults
