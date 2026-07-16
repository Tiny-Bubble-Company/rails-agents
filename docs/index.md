---
layout: home

hero:
  name: Rails Agents
  text: Agents for your Rails app
  tagline: Add app/agents/…/instructions.md. Test locally. Deploy to Cloud. Zero Render cron glue.
  image:
    src: /logo-dark.svg
    alt: Rails Agents
  actions:
    - theme: brand
      text: Get started
      link: /guide/getting-started
    - theme: alt
      text: Why Rails Agents
      link: /guide/why
    - theme: alt
      text: Share a use case
      link: https://github.com/Tiny-Bubble-Company/rails-agents/discussions/1
    - theme: brand
      text: Open Cloud
      link: https://agents.meerkatagents.com
    - theme: alt
      text: GitHub
      link: https://github.com/Tiny-Bubble-Company/rails-agents

features:
  - title: Directory DX
    details: Your agent is app/agents/name/instructions.md — Eve-shaped. rails-agents new · test · deploy.
  - title: Your tools
    details: Tool Bridge calls your Rails models, jobs, and services. Secrets stay in your app.
  - title: Cloud by default
    details: Hosted runtime + dashboard at agents.meerkatagents.com. Prepaid Credits before hosted runs.
  - title: Sandbox → production
    details: Build with a sandbox key, subscribe, deploy. Same agent directory in production.
---

<div class="home-code">

```ruby
class LeadQualifier < RailsAgents::Agent
  model "anthropic/claude-sonnet-5"
  description "Qualifies inbound leads and creates a CRM note when promising."
  tools "SearchCrm", "CreateCrmNote"
end

LeadQualifier.run("New signup from acme.com — 50 employees, enterprise pricing")
```

</div>
