# Tenancy model — one Vercel project, logical isolation

**Decision:** All customer workloads run on **one** Tiny Bubble Vercel project (Eve runtime + Workflow + Sandbox + AI Gateway). Isolation is **logical**, not “one Vercel project per customer.”

This mirrors serverless practice: one shared platform, hard account boundaries in software.

---

## Identity

Every request is stamped with:

| Field | Values | Source |
|-------|--------|--------|
| `tenant_id` | UUID | Derived from API key → org/app |
| `environment` | `sandbox` \| `production` | API key scope or explicit header |
| `app_id` | UUID | Customer “app” under the org |
| `agent_id` | string slug | e.g. `lead_qualifier` |

Composite runtime key:

```text
{tenant_id}/{environment}/{app_id}/{agent_id}
```

---

## Two environments per tenant app

| Env | Purpose | Billing |
|-----|---------|---------|
| `sandbox` | Build, playground, evals, low limits | Free / capped credits |
| `production` | Live traffic after Stripe | Metered + subscription |

Each env has its **own API keys**. Promoting sandbox → production copies the compiled agent bundle and flips the customer’s default endpoint — same Vercel project, different logical namespace.

---

## What is shared vs isolated

### Shared (one Vercel project)

- Eve HTTP host + Workflow world
- Sandbox backend pool (`vercel()`)
- AI Gateway routing
- Control plane Next.js dashboard (can be same or adjacent deployment)

### Isolated per `tenant_id` + `environment`

| Concern | Mechanism |
|---------|-----------|
| Auth | API key → tenant/env claims; reject cross-env keys |
| Sessions / turns | Workflow session metadata + storage keys prefixed by composite key |
| Agent definitions | Object store / DB: compiled Eve tree per composite key; hot-loaded or deployed as versioned artifacts |
| Tool Bridge | Per-app webhook URL + HMAC secret; cloud only calls that tenant’s Rails app |
| Secrets | Vault/DB encrypted by tenant; never injected into other tenants’ sandbox env |
| Quotas | Rate limits & daily token caps keyed by tenant+env |
| Logs / traces | Query filters mandatory `tenant_id` + `environment`; UI never cross-leaks |
| Billing | Stripe customer ↔ tenant; production env blocked without payment method |

---

## Request path

```text
Rails gem
  Authorization: Bearer rak_sandbox_xxx
       │
       ▼
Control plane API
  resolve key → {tenant_id, app_id, environment}
  authorize agent_id belongs to app
       │
       ▼
Eve session create/continue
  auth attributes: { tenantId, environment, appId, agentId }
  load agent artifact for that composite key
  run durable turn (Workflow)
       │
       ▼ (on tool call for Rails tool)
Tool Bridge
  POST https://customer.example/rails_agents/bridge
  X-Rails-Agents-Signature + tenant/app/env headers
       │
       ▼
Customer Rails tool#call → JSON result → model
```

---

## Agent artifacts (not separate Vercel projects)

Instead of provisioning a Vercel project per tenant:

1. Developer syncs `app/agents/**` via gem / CI → control plane.
2. Compiler emits an Eve-compatible `agent/` tree + tool shims (Tool Bridge).
3. Artifact stored as versioned bundle: `artifacts/{tenant}/{env}/{app}/{agent}/{version}/`.
4. Runtime **router** selects the bundle from auth claims before starting a session.

Optional later optimization: warm a small set of Eve “slots” or use dynamic `defineRemoteAgent` / extension mounts — still one project.

---

## Security invariants (non-negotiable)

1. Every DB query for sessions/traces/artifacts includes `tenant_id` (+ `environment` when env-scoped).
2. API keys are hashed at rest; plaintext shown once.
3. Sandbox keys cannot call production agents (and vice versa).
4. Tool Bridge signatures verify body + timestamp; replay window ≤ 5 minutes.
5. Sandbox filesystem / bash cannot read other tenants’ data (Vercel Sandbox session isolation + no shared workspace seeds with secrets).
6. Dashboard RLS: session cookie → tenant membership only.

---

## Capacity & abuse

- Per-tenant concurrency limits on open sessions
- Sandbox daily token/message caps
- Production soft/hard quotas with Stripe meters
- Kill switch per tenant in admin

---

## Why not one Vercel project per tenant?

| One project / tenant | One project + logical isolation |
|----------------------|----------------------------------|
| Clean hard boundary | Soft boundary we must enforce |
| Hits Vercel project limits / ops cost | Scales to many tenants |
| Slow signup (provision) | Instant sandbox on signup |
| Harder shared dashboards | Natural multi-tenant control plane |

We accept software isolation discipline in exchange for signup speed and cost — matching the “serverless shared infra” model you chose.
