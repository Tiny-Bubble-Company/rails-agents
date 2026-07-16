---
layout: home

hero:
  name: Rails Agents
  text: Like Eve for Rails
  tagline: Your agent is a directory. Durable cloud runtime. Deploy without Render cron glue.
  image:
    src: /logo-dark.svg
    alt: Rails Agents
  actions:
    - theme: brand
      text: Get started
      link: /guide/getting-started
    - theme: brand
      text: Open Cloud
      link: https://agents.meerkatagents.com
    - theme: alt
      text: Why Rails Agents
      link: /guide/why
    - theme: alt
      text: GitHub
      link: https://github.com/Tiny-Bubble-Company/rails-agents

features:
  - title: Your agent/ is a directory
    details: instructions.md is a complete agent. Schedules, tools, and skills are optional blocks you add as it grows — Eve-shaped, Rails-native.
  - title: Durable by default
    details: Checkpointed runs on Rails Agents Cloud. Agents park between turns, resume on delivery, and survive deploys — not a fire-and-forget chat call.
  - title: Hosted schedules
    details: Drop schedules/poll.yml and deploy. Cloud runs the cron. No Render workers, no rake task glue for ADC→FTP-style jobs.
  - title: Tool Bridge into Rails
    details: Models, jobs, and services stay in your app. Secrets never leave your Rails process. The cloud runtime calls back securely.
  - title: new · test · deploy
    details: rails-agents new, rails-agents test, rails-agents deploy. Signup and subscribe from the CLI when you go production.
  - title: Built for production agents
    details: Dashboard status, run logs, prepaid Credits. Choose RubyLLM for a multimodal toolkit you host — choose us for durable agents that ship.
---

<div class="home-code">

```bash
rails-agents new accidental_damage_sync
# edit app/agents/accidental_damage_sync/instructions.md
rails-agents test accidental_damage_sync
rails-agents deploy accidental_damage_sync
```

```text
app/agents/accidental_damage_sync/
  instructions.md      # complete agent
  schedules/poll.yml   # hosted cron after deploy
  tools/               # optional Tool Bridge helpers
```

</div>
