# Why Rails Agents

Agents today are where the web was before frameworks — everyone hand-rolling the same plumbing. Eve made that shape a framework for TypeScript. **Rails Agents is that shape for Rails.**

An agent is a directory. Production — durable execution, hosted schedules, Tool Bridge, dashboard — ships with the product.

## An agent is a directory

```text
app/agents/accidental_damage_sync/
  agent.json                 # the model it runs on
  instructions.md            # who it is
  tools/                     # what it can do
  skills/                    # what it knows
  schedules/                 # when it acts on its own
```

Each file is one component. At a glance you see what the agent is, what it does, and when it runs.

## Batteries included

| | |
|---|---|
| **Durable execution** | Checkpointed runs. Park between messages. Resume on delivery. |
| **Hosted schedules** | Cron from `schedules/` after deploy — no Render workers. |
| **Tool Bridge** | Signed callbacks into your Rails app. Secrets stay home. |
| **Dashboard** | Status, runs, logs at [agents.meerkatagents.com](https://agents.meerkatagents.com). |
| **CLI** | `rails-agents new · test · deploy` |

## vs RubyLLM

RubyLLM is an excellent **LLM toolkit** you host. Rails Agents is the **agent product path**: directory → durable cloud → schedules.

→ [Getting Started](/guide/getting-started) · [Home](/)
