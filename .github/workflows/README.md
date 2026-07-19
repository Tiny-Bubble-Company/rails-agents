# GitHub Actions

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | push/PR to `main` | RSpec + gem build |

This repo is the **Ruby gem** (`rails-agent-stack`). It has **no Hetzner deploy** — customers install from GitHub:

```ruby
gem "rails-agent-stack", github: "Tiny-Bubble-Company/rails-agents"
```

Production sites deploy from sibling repos:

- [`rails-agents-cloud`](https://github.com/Tiny-Bubble-Company/rails-agents-cloud) → rails-agent.com
- [`rails-agents-ops`](https://github.com/Tiny-Bubble-Company/rails-agents-ops) → ops.rails-agent.com
