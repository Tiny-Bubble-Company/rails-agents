# Pricing & revenue model — map to Vercel, money from day 1

**North star growth loop (bootstrap — you have $0 CAC budget)**

```text
gem installs → free signup (no LLM spend) → card / prepaid credits
            → first real .run on our Vercel → margin → scale installs
```

Your job: **maximize installs and paid conversion**.  
Vercel’s job: **supply AI + compute**.  
Our product: **Rails DX + tenancy + billing glue**, with margin on every dollar of infra we resell.

**Who funds LLM/sandbox usage?** Always the **customer** (prepaid Credits), never Tiny Bubble’s pocket.  
Vercel’s ~$5/mo team free credit is only a tiny buffer for *your* account ops — not a per-developer gift.

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

> Customers buy **Credits** that we spend on Vercel (Gateway / Sandbox / Fluid) at cost × margin.  
> Free = **product access without burning our money** (signup, keys, define agents, dashboard).  
> **First token / sandbox second requires prepaid balance.**

---

## 2. Customer tiers (bootstrap-safe)

### A. Free — Build mode (no infra spend on us)

Goal: install gem, sign up, define agents, see dashboard — **zero Vercel AI/Sandbox cost to Tiny Bubble**.

| Dimension | Policy |
|-----------|--------|
| Signup / API keys | Free (`rak_sandbox_…` issued, **inactive for runs** until funded) |
| Define agents / sync manifests | Free |
| Dashboard UI | Free (empty playground until funded) |
| `.run` / playground LLM | **Blocked** until Credits ≥ minimum top-up |
| Production | Blocked |

Optional free path that still costs you $0: **BYOK** — customer pastes their own OpenAI/Anthropic key for sandbox-only testing; we only charge when they use *our* Gateway/Sandbox.

### B. Paid — Prepaid Credits (required before any hosted run)

**You never front LLM cost.** Customer tops up first; we spend from their balance on Vercel + keep margin.

| Dimension | Policy |
|-----------|--------|
| Stripe | Card + **minimum top-up** (e.g. **$10** Rails Agents Credits) before first `.run` |
| Platform | **$29/mo** when they enable production (or from first top-up — pick one) |
| Env | Funded sandbox; production after subscribe |
| Models | Gateway catalog we enable (free-tier models still cheaper) |
| Infra | Metered: `vercel_cost × (1 + margin)` debited from their Credits |

Minimum top-up covers: first real agent runs + your margin + Stripe fees. If balance hits $0 → hard stop (`PaymentRequired`).

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

| Action | Free (unfunded) | Funded (Credits > 0) |
|--------|-----------------|----------------------|
| Signup + sandbox key | ✅ | ✅ |
| Define / sync agents | ✅ | ✅ |
| `.run` / playground (our Gateway) | ❌ → top up | ✅ |
| BYOK sandbox (optional) | ✅ (their key) | ✅ |
| Production keys | ❌ | ✅ after subscribe |
| Promote to production | ❌ → Stripe | ✅ |

API when unfunded:

```json
{
  "error": {
    "code": "payment_required",
    "message": "Add Credits to run agents on Rails Agents Cloud.",
    "checkout_url": "https://cloud…/billing"
  }
}
```

HTTP `402`. Gem: `RailsAgents::PaymentRequired`.

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

## 6. Stripe packaging (day-1 simple — no float)

**Plan: Rails Agents Cloud**

- **Minimum first purchase: $10 Credits** (required before hosted `.run`)  
- **Usage:** prepaid wallet only — we never extend credit  
  - Top-ups: $10 / $25 / $50 / $100 / $500  
  - Burn: Vercel meters × margins  
- **$29/mo** when enabling **production** (sandbox can be credits-only at first)  

Cashflow: Stripe settles → you top up Vercel Gateway / pay Pro invoice. Keep a small Vercel balance; pause runs if Vercel balance &lt; safety threshold.

---

## 7. Bootstrap economics (you have no money)

| Rule | Why |
|------|-----|
| No free hosted LLM/sandbox | You cannot subsidize strangers |
| Prepaid only | Customer funds Vercel spend + your margin |
| Optional BYOK for curiosity | Lets them feel DX at $0 cost to you |
| Vercel $5 team free | Ops buffer only — ignore in customer pricing |
| Pro plan required | Commercial multi-tenant; budget Pro from first Credit sales |

If someone asks “is there a free trial?” →  
“Free to install and build. **$10 to run** on our cloud (Credits). Or bring your own API key for sandbox.”

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

> Free to install and define agents. **Add $10 Credits** to run on Rails Agents Cloud (or BYOK in sandbox). Production = subscribe. Usage = Vercel infra + transparent margin.

**Paywall**

> Hosted runs need Credits. Top up to continue — we don’t offer a free LLM allowance.

---

## 10. Decisions locked here

| Topic | Choice |
|-------|--------|
| Who funds runs | **Customer prepaid Credits only** |
| Free | Signup + build DX; **no free hosted tokens** |
| Optional $0 test | **BYOK** sandbox |
| First hosted run | Min **$10** top-up |
| Usage pricing | Vercel cost × (1 + margin), 1-1 meters |
| Growth focus | Installs → funded accounts → margin volume |
| Hobby Vercel | **Do not** — use Pro, paid from Credit sales |

Tune `M_*` after the first 50 paid runs with real invoices.
