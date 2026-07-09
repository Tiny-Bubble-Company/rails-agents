# Why Rails Agents

Rails Agents competes on **simplicity** — not on having the most features.

The best agent framework for Rails is the one that gets out of your way: a small gem, a familiar DSL, and a straight line from idea to working code.

## What we optimize for

| Priority | What it means |
|----------|---------------|
| **Developer experience** | One mental model, one agent class, a DSL that reads like Ruby |
| **Speed to implementation** | `rails generate`, drop a class in `app/agents/`, call `.run` |
| **Lightweight** | API keys in an initializer — no engine, no control plane, no telemetry |
| **Ease of getting started** | Three required declarations. Everything else is optional |
| **Rails-native** | Your tools are your models, jobs, and services |

## What we deliberately don't build

Chat persistence, model registries, agent versioning, hosted dashboards, or a general-purpose AI toolkit. Other gems do those well. We stay focused on one job:

> Get a working agent into your Rails app with the least code and the least ceremony.

## Who this is for

- You want an agent **today**, not after reading a framework manual
- You already have Rails app code you want the model to call
- You prefer **one class per use case** over configuring agent types and lifecycles
- You want provider differences handled for you, without giving up control

## vs RubyLLM

[RubyLLM](https://rubyllm.com) is an excellent general-purpose AI framework — chat, images, embeddings, 800+ models, Rails chat persistence. It's the right choice when you want a **full AI toolkit**.

<div class="comparison">
  <div class="comparison-card">
    <h3>Use RubyLLM when…</h3>
    <p>You need multimodal AI, embeddings, model discovery, or chat persistence.</p>
  </div>
  <div class="comparison-card">
    <h3>Use Rails Agents when…</h3>
    <p>You want the fastest path from gem install to a working agent — one class, one description, your tools, done.</p>
  </div>
</div>

| | RubyLLM | Rails Agents |
|---|---------|--------------|
| **Goal** | Broad AI framework | Agents only |
| **Mental model** | `RubyLLM.chat` + `RubyLLM::Agent` | One class: `RailsAgents::Agent` |
| **Configuration** | API keys + model registry + many options | API keys in initializer; model on each agent |
| **What defines behavior** | `instructions`, `tools`, `model`, … | **`description`** — what the agent does |
| **Rails integration** | `acts_as_chat`, persistence | Initializer + `app/agents/` |

## vs rolling your own

You could wire OpenAI or Anthropic HTTP calls directly. Rails Agents gives you a thin layer so you don't re-solve:

- Multi-turn tool loops
- Provider-specific request/response shapes
- Anthropic skills, server tools, and file downloads
- Portable fallbacks when a skill isn't native to your provider

The gem stays small on purpose. You keep full control of your agents and tools; we handle the plumbing.

## Next

Ready to try it? → [Getting Started](/guide/getting-started)
