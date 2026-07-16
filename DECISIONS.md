# Locked product decisions (2026-07-16)

| # | Decision | Choice |
|---|----------|--------|
| 1 | Runtime strategy | **Compile-to-Eve** — Ruby DSL compiles onto Eve; we do not reimplement Workflow/Sandbox in Ruby |
| 2 | Gem default | **Cloud-only** — no BYOK local runtime as a supported product path |
| 3 | Dashboard | **Next.js** control plane + Agno-like UX |
| 4 | Tenancy | **One Vercel project**, logical isolation by `tenant_id` + `environment` (sandbox \| production) — like serverless account separation on shared infra |
| 5 | Docs hosting | **GitHub Pages** (existing VitePress site) |

See [TENANCY.md](./TENANCY.md) for the isolation model and [docs/protocol/](./docs/protocol/) for Tool Bridge + compiler contracts.

---
