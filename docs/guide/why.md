# Why Rails Agents

Rails Agents competes on **simplicity** — the fastest path from a Rails idea to a production agent.

A small Ruby DSL, Tool Bridge into your app, and **cloud by default** (durable Eve runtime on our Vercel infra). You never manage Node, Workflow, or sandboxes.

## What we optimize for

| Priority | What it means |
|----------|---------------|
| **Developer experience** | One mental model: `RailsAgents::Agent` |
| **Speed to production** | Signup → define agent → add Credits → `.run` → promote |
| **Zero infra for you** | We run models, durability, and sandbox; you write Ruby |
| **Rails-native tools** | Tool Bridge calls your models, jobs, and services |
| **Honest billing** | Prepaid Credits = Vercel cost + margin — no free hosted tokens |

## What we deliberately don't build

A general-purpose multimodal AI toolkit, or “bring your own Vercel/Eve account.” Other tools do that. We stay focused on:

> Fastest Rails path to a working agent — least code, cloud included, pay for what you run.

## Who this is for

- You want an agent in your Rails app **today**
- You already have app code the model should call
- You prefer **one class per use case** over framework sprawl
- You’re fine with prepaid cloud Credits (or BYOK in sandbox)

## vs RubyLLM

[RubyLLM](https://rubyllm.com) is an excellent general-purpose AI framework — chat, images, embeddings, Rails chat persistence. Choose it for a **full AI toolkit** you host yourself.

<div class="comparison">
  <div class="comparison-card">
    <h3>Use RubyLLM when…</h3>
    <p>You need multimodal AI, embeddings, model discovery, or chat persistence in your own stack.</p>
  </div>
  <div class="comparison-card">
    <h3>Use Rails Agents when…</h3>
    <p>You want the fastest path to a durable production agent in Rails — gem + Credits, no infra.</p>
  </div>
</div>

## Next

→ [Getting Started](/guide/getting-started) · [Billing / PRICING](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/PRICING.md)
