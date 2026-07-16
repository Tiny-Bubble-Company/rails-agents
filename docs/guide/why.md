# Why Rails Agents

**Like Eve for Rails.** Your agent is a directory. Durable execution, hosted schedules, and Tool Bridge into your app — without managing Node, Workflow, or Render cron yourself.

Eve’s pitch is right: production agents need more than a chat loop. Rails Agents brings that model to Ruby — with a Rails-native DX and cloud that ships.

## What makes it special

| Capability | What you get |
|------------|--------------|
| **Directory DX** | `app/agents/<name>/instructions.md` is a complete agent. Optional `schedules/`, `tools/`, skills as it grows. |
| **Durable execution** | Checkpointed runs on Rails Agents Cloud. Park between turns, resume on delivery. Survives crashes and deploys. |
| **Hosted schedules** | Cron in `schedules/poll.yml` after `rails-agents deploy` — no Render workers for polling jobs. |
| **Tool Bridge** | Cloud calls your Rails models/jobs/services. Credentials stay in your app. |
| **CLI path** | `rails-agents new \| test \| deploy` — signup/subscribe when you go live. |
| **Honest billing** | Prepaid Credits before hosted runs. Free to build; pay for what you run. |

## What we optimize for

| Priority | In practice |
|----------|-------------|
| **Speed to production** | Directory → test → deploy → dashboard |
| **Durability** | Cloud runtime owns persistence and schedules |
| **Rails-native tools** | Your existing code, not a second stack |
| **Zero agent infra for you** | We run the durable runtime; you write Markdown + Ruby |

## vs RubyLLM

[RubyLLM](https://rubyllm.com) is an excellent **general-purpose AI toolkit** — chat, images, embeddings, model registry, Rails chat persistence. You host it and own the runtime.

| | **RubyLLM** | **Rails Agents** |
|---|-------------|------------------|
| **Job** | Broad LLM SDK for Rails | **Production agents** — durable, scheduled, deployable |
| **Shape** | `RubyLLM.chat` + rich macros | Agent **directory** + `instructions.md` (+ optional class DSL) |
| **Runtime** | Your process / your infra | **Cloud** — checkpointed runs, park/resume, hosted cron |
| **Ops** | You wire Sidekiq/cron/hosts | `rails-agents deploy` + dashboard status & logs |
| **Tools** | In-process tool classes | Tool Bridge — tools stay in *your* Rails app |
| **Best when** | Multimodal toolkit, embeddings, DIY persistence | Durable agents that must survive deploys and run on a schedule |

**Use RubyLLM** when you need a full AI SDK you control end-to-end.

**Use Rails Agents** when you want Eve-style durability for Rails: directory in, deploy out, cloud runs the hard parts.

## vs rolling your own

You could call provider APIs and hang a rake task on Render. You’d re-solve:

- Multi-turn tool loops and provider shapes  
- Crash-safe state between messages  
- Cron that doesn’t die with a dyno restart  
- Secure callbacks into Rails for DB/FTP/CRM  
- A place to see runs and failures  

That’s the product. We ship it as gem + Cloud.

## Next

→ [Getting Started](/guide/getting-started) · [Cloud](https://agents.meerkatagents.com) · [Billing](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/PRICING.md)
