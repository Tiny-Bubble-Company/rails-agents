# Tools

**Tools** are your app code — the agent calls them when it needs data or side effects.

Drop tool classes in `app/agents/tools/` (auto-loaded) or declare them on the agent.

## Define a tool

```ruby
# app/agents/tools/search_docs.rb
class SearchDocs < RailsAgents::Tool
  description "Search product documentation"
  param :query, :string

  def call(query:)
    Documentation.search(query).limit(5).pluck(:title)
  end
end
```

Attach it to an agent:

```ruby
# app/agents/doc_agent.rb
class DocAgent < RailsAgents::Agent
  provider :openai
  model "gpt-4o-mini"
  description "Answer questions using internal docs."
  tools "SearchDocs"
end
```

## Parameters

Use `param` to declare what the model must pass:

```ruby
class CreateCrmNote < RailsAgents::Tool
  description "Create a CRM note for a lead"
  param :company, :string, description: "Company name"
  param :summary, :string, description: "Short note body"
  param :score, :integer, required: false, description: "Lead score 1–10"

  def call(company:, summary:, score: nil)
    CrmNote.create!(company:, summary:, score:)
    "Note created for #{company}"
  end
end
```

| Option | Default | Meaning |
|--------|---------|---------|
| type | required | `:string`, `:integer`, `:number`, `:boolean`, … |
| `required:` | `true` | Whether the model must supply the argument |
| `description:` | `nil` | Hint shown to the model |

## String vs constant names

::: tip Prefer strings in `app/agents/`
Declare tools as **strings** when the agent lives in `app/agents/` (e.g. `tools "SearchDocs"`).

Ruby otherwise looks up constants under the agent class first (`LeadQualifier::SearchCrm`). You can also use `tools ::SearchDocs`.
:::

## What to put in a tool

Anything your Rails app already does:

- ActiveRecord queries and writes
- Service objects
- Background job enqueues
- HTTP calls to internal APIs

Keep tools focused. One responsibility per class makes the model's choices clearer.

## Minimal example

```ruby
# app/agents/tools/current_time.rb
class CurrentTime < RailsAgents::Tool
  description "Returns the current time in UTC"
  def call = Time.now.utc.iso8601
end

class ClockAgent < RailsAgents::Agent
  provider :openai
  model "gpt-4o-mini"
  description "Tell the user the current time using the tool."
  tools "CurrentTime"
end

ClockAgent.run("What time is it?")
```

## Next

- [Skills](/guide/skills) — built-in capabilities vs your tools
- [Recipes](/guide/recipes) — more patterns
