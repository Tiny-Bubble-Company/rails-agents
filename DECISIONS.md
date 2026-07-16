# Locked product decisions (2026-07-16)

| # | Decision | Choice |
|---|----------|--------|
| 1 | Runtime strategy | **Compile-to-Eve** — Ruby DSL compiles onto Eve; we do not reimplement Workflow/Sandbox in Ruby |
| 2 | Gem default | **Cloud-only** — no BYOK local runtime as a supported product path |
| 3 | Dashboard | **Next.js** control plane + Agno-like UX |
| 4 | Tenancy | **One Vercel project**, logical isolation by `tenant_id` + `environment` (sandbox \| production) — like serverless account separation on shared infra |
| 5 | Docs hosting | **GitHub Pages** (existing VitePress site) |
| 6 | Revenue | **Customer prepaid Credits only** (min $10 before hosted `.run`); free = build/signup only; optional BYOK; Vercel cost × margin — see [PRICING.md](./PRICING.md) |
| 7 | Agent DX | **Directory-first (Eve-shaped)** — `app/agents/<name>/instructions.md` is a complete agent; `RailsAgents["name"].run` syncs then runs on Cloud |
| 8 | CLI | **`rails-agents new \| test \| deploy`** — replace rake+Render cron; deploy opens signup/subscribe then dashboard |
| 9 | Cloud host | **Hetzner** beside Meerkat (`/opt/meerkat-apps/rails-agents-cloud`, `agents.meerkatagents.com` via shared Caddy) — not a separate Vercel control plane for v1 |
| 10 | Reference job | **Weather brief** — morning schedule + Tool Bridge tools; default scaffold/docs |
| 11 | Host Web UI | **`mount … => "/agents"`** (Sidekiq-style) — signup + agents list on host domain; deep-link Cloud for billing |

See [TENANCY.md](./TENANCY.md) for the isolation model, [PRICING.md](./PRICING.md) for billing, and [docs/protocol/](./docs/protocol/) for Tool Bridge + compiler contracts.

---
