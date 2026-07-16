---
layout: home

hero:
  name: Rails Agents
  text: Agents for your Rails app
  tagline: Define an agent in Ruby. Add Credits. Call .run. Durable cloud runtime — zero infra for you.
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
    - theme: alt
      text: GitHub
      link: https://github.com/Tiny-Bubble-Company/rails-agents

features:
  - title: One class
    details: Every agent is a subclass of RailsAgents::Agent. Model, description, tools — then .run on Rails Agents Cloud.
  - title: Your tools
    details: Tool Bridge calls your Rails models, jobs, and services. Secrets stay in your app.
  - title: Cloud by default
    details: Durable Eve runtime on our Vercel infra. Prepaid Credits = infra cost + margin. Optional BYOK in sandbox.
  - title: Sandbox → production
    details: Build with a sandbox key, subscribe, promote, switch to rak_live_…. Same Ruby code.
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
