# Pricing & revenue model — map to Vercel, money from day 1

**North star growth loop**

```text
gem installs  →  sandbox signup (free trial)  →  subscribe (card on file)
              →  usage on our Vercel infra    →  margin  →  scale installs
```

Your job: **maximize installs and paid conversion**.  
Vercel’s job: **supply AI + compute**.  
Our product: **Rails DX + tenancy + billing glue**, with margin on every dollar of infra we resell.

---

## 1. Critical constraint (read this first)

Vercel free allowances are **per Vercel team**, not per end customer.

| Vercel free (your team) | What it is NOT |
|-------------------------|----------------|
| ~**$5/mo AI Gateway** credits (free-tier models, rate-limited) | $5 free for every Rails developer |
| Hobby Sandbox allotments (only if on Hobby) | Usable for commercial multi-tenant SaaS |

**Commercial Rails Agents Cloud must run on Vercel Pro** (or Enterprise). Hobby is non-commercial. So your cost base is:

1. Vercel **Pro** seat/base  
2. **AI Gateway** credits (list price, $0 markup from Vercel)  
3. **Fluid compute** (Functions / Eve host)  
4. **Sandbox** Active CPU + memory + creations + transfer  
5. Workflow / bandwidth / misc  

Therefore “1-1 free with Vercel” means:

> **Mirror Vercel’s free-tier *product shape*** (limited models, tight rate limits, tiny credit, try-then-pay) — **not** “give every signup $5 of Vercel credits forever.”

We fund a **shared sandbox trial pool** from our team free credits + a small CAC budget. Continued use requires payment.

---

## 2. Customer tiers (product)

### A. Free — Sandbox trial (“experience the full flow”)

Goal: complete the happy path once — signup → agent → `.run` → playground → traces — then hit paywall.

| Dimension | Policy (maps to Vercel free shape) |
|-----------|-------------------------------------|
| Env | `sandbox` only (`rak_sandbox_…`) |
| Models | **Free-tier allowlist only** (same spirit as Vercel AI Gateway free models) |
| Credits | Fixed trial wallet, e.g. **$3–5 equivalent** of Gateway+compute once per org (not monthly forever) |
| Rate limits | Strict (mirror Gateway free 429 behavior) |
| Features | Full DX: define agent, Tool Bridge, playground, run list, 1–2 evals |
| Production | **Blocked** |
| After wallet empty / trial days | **Hard stop** until subscribe |

Suggested defaults (tune after week-1 cost data):

- **7 days** or **$5 metered wallet**, whichever first  
- Cap: e.g. 50 agent turns / 200k tokens / 30 min sandbox CPU  
- One app, two agents max  

When blocked, UI: “Subscribe to continue — same product, production keys, full model catalog.”

### B. Paid — Subscriber (required to keep using)

**Nothing meaningful continues without a card.** Production always requires Paid.

| Dimension | Policy |
|-----------|--------|
| Stripe | Card on file + subscription (or prepaid credits) |
| Env | `sandbox` (higher limits) + `production` (`rak_live_…`) |
| Models | Full Gateway catalog we enable |
| Infra | Metered pass-through of **our Vercel cost** × **(1 + margin)** |
| Platform | Small base subscription (covers Pro overhead + support) |

---

## 3. 1-1 cost → price mapping (the money engine)

Every billable unit we expose to customers maps to a Vercel meter:

| Customer line item | Vercel cost driver | How we charge |
|--------------------|--------------------|---------------|
| Model tokens | AI Gateway credits (provider list) | `gateway_cost × (1 + M_ai)` |
| Agent turn / function time | Fluid Active CPU + memory + invocations | `compute_cost × (1 + M_compute)` |
| Sandbox session | Sandbox Active CPU + memory + creation + transfer | `sandbox_cost × (1 + M_sandbox)` |
| Platform | Pro base amortized | Flat **$X/mo per app** or per org |

**Margin knobs (start simple):**

| Knob | Suggested start | Notes |
|------|-----------------|-------|
| `M_ai` | **30%** | Primary revenue; easy to explain |
| `M_compute` | **40%** | Spikier; keep buffer |
| `M_sandbox` | **40%** | Same |
| Platform fee | **$29/mo per production app** | Covers Pro + dashboard + support |

Formula for a usage event:

```text
customer_charge = vercel_cost_usd * (1 + margin) + platform_fee_proration
our_gross_margin = customer_charge - vercel_cost_usd - stripe_fees
```

**Rule:** never sell below Vercel cost. Auto top-up our Gateway credits from Stripe cash; pause tenant if our Vercel balance is low.

---

## 4. Paywall gates (enforce in control plane)

| Action | Free trial | Paid |
|--------|------------|------|
| Signup + sandbox key | ✅ | ✅ |
| `.run` / playground | ✅ until wallet/day cap | ✅ |
| Sync agents | ✅ (limits) | ✅ |
| Full model catalog | ❌ | ✅ |
| Production keys | ❌ | ✅ |
| Promote to production | ❌ → Stripe Checkout | ✅ |
| Continue after trial exhausted | ❌ → Subscribe | ✅ |
| Slack/channels (later) | ❌ | ✅ |

API responses when unpaid/exhausted:

```json
{
  "error": {
    "code": "payment_required",
    "message": "Sandbox trial ended. Subscribe to continue.",
    "checkout_url": "https://cloud…/billing"
  }
}
```

HTTP `402` or `403` with that body. Gem surfaces a clear `RailsAgents::PaymentRequired` error.

---

## 5. Why this is “1-1 with Vercel” for *your* business

```text
Customer pays us ──► we pay Vercel (Gateway + Sandbox + Fluid + Pro)
                 └──► we keep margin + platform fee
```

You do **not** invent a separate AI economy. You:

1. Meter the same units Vercel meters (tokens, CPU, sandbox).  
2. Price = their cost + margin.  
3. Free tier = Vercel free-tier *experience* (limited models + tight limits + small try credit).  
4. Scale revenue by scaling **gem installs → paid orgs → usage**.

Focus metrics (in order):

1. `gem installs` / weekly unique `rak_sandbox_` creations  
2. `% trial → paid` (card + subscribe)  
3. `gross margin $` = collected − Vercel − Stripe  
4. `usage $ / paid org`  

---

## 6. Stripe packaging (day-1 simple)

**Plan: Rails Agents Cloud**

- **$29/mo** platform (includes 1 production app, sandbox + production env)  
- **Usage:** prepaid **Rails Agents Credits** (USD wallet)  
  - Top-ups: $20 / $50 / $100 / $500  
  - Burn rate: Vercel meters × margins above  
- Trial: $5 wallet, no card; card required to top up or promote  

Optional later: usage-only (no platform fee) for indie — only after margins proven.

---

## 7. Free-pool economics (protect yourself)

Shared trial pool per month (example):

```text
budget = min(
  our_vercel_ai_free_credits,          # ~$5 team — almost nothing at scale
  + intentional_cac_budget             # e.g. $200/mo you choose to burn
)
per_org_trial = $5 equivalent
max_concurrent_trials ≈ budget / per_org_trial
```

When pool is tight: shorten trial, lower caps, or require card for *any* model call (trial becomes “UI tour only”). **Never** let free users unbounded-drain Pro Sandbox/Gateway.

---

## 8. Implementation checklist (control plane)

- [ ] `organizations.trial_wallet_cents`, `trial_ends_at`, `stripe_customer_id`, `plan_status`  
- [ ] Meter every Eve/Gateway/Sandbox call with `tenant_id` + cost estimate  
- [ ] Debit wallet before/after run; reject with `payment_required`  
- [ ] Stripe Checkout for subscribe + credit top-up  
- [ ] Promote to production only if `plan_status == active`  
- [ ] Admin: Vercel credit balance alert → pause new free signups  
- [ ] Gem: raise `PaymentRequired` with dashboard URL  

---

## 9. Messaging (install → pay)

**Gem / docs**

> Free sandbox to run your first agent. Subscribe to keep building and go to production — powered by Vercel AI infra, billed simply in Rails Agents Credits.

**Paywall**

> You’ve finished the free sandbox trial (same idea as Vercel’s free AI tier: limited models & credits). Add a card to unlock full models, higher limits, and production keys. Usage maps to cloud infra + a transparent margin.

---

## 10. Decisions locked here

| Topic | Choice |
|-------|--------|
| Free | Trial wallet + free-tier models + hard caps (Vercel free *shape*) |
| Continue / production | **Paid only** (card + subscribe) |
| Usage pricing | Vercel cost × (1 + margin), 1-1 meters |
| Growth focus | Installs → trial → subscribers → margin volume |
| Hobby Vercel | **Do not** host commercial cloud on Hobby — use Pro |

Tune `M_*` and trial size after the first 50 paid runs with real invoices.
