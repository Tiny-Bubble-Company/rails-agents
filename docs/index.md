---
layout: home

hero:
  name: Rails Agents
  text: Agents for your Rails app
  tagline: Define an agent in Ruby. Call .run. Durable cloud runtime by default — sandbox to production with zero infra.
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
    details: Every agent is a subclass of RailsAgents::Agent. Three declarations — provider, model, description — and you're running.
  - title: Your tools
    details: Drop Ruby classes in app/agents/tools/. The model calls your models, jobs, and services — not a foreign plugin API.
  - title: Built-in skills
    details: Web search, fetch, spreadsheets, PDFs, and more. Native on Anthropic; portable fallbacks elsewhere.
  - title: Unified providers
    details: OpenAI, Anthropic, OpenRouter, and Grok behind one DSL. The gem translates the API differences.
---

<div class="home-code">

```ruby
class LeadQualifier < RailsAgents::Agent
  provider :openrouter
  model "meta-llama/llama-3.3-70b-instruct:free"
  description "Qualifies inbound leads and creates a CRM note when promising."
  tools "SearchCrm", "CreateCrmNote"
end

LeadQualifier.run("New signup from acme.com — 50 employees, enterprise pricing")
```

</div>
