# Recipes

Copy-paste patterns for common agent setups.

## Tool + agent

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

## CRM lead qualifier

```ruby
# app/agents/tools/search_crm.rb
class SearchCrm < RailsAgents::Tool
  description "Search CRM for a company"
  param :query, :string

  def call(query:)
    Company.search(query).limit(5).map { |c| { name: c.name, plan: c.plan } }
  end
end

# app/agents/tools/create_crm_note.rb
class CreateCrmNote < RailsAgents::Tool
  description "Create a CRM note for a promising lead"
  param :company, :string
  param :note, :string

  def call(company:, note:)
    CrmNote.create!(company:, body: note)
    "Saved note for #{company}"
  end
end

class LeadQualifier < RailsAgents::Agent
  provider :openrouter
  model "meta-llama/llama-3.3-70b-instruct:free"
  description "Qualify inbound leads and create CRM notes for promising ones."
  tools "SearchCrm", "CreateCrmNote"
end

LeadQualifier.run("New signup from acme.com — 50 employees, asked about enterprise pricing")
```

## OpenRouter free model

```ruby
class CheapAgent < RailsAgents::Agent
  provider :openrouter
  model "meta-llama/llama-3.3-70b-instruct:free"
  description "Answer briefly."
end

CheapAgent.run("What is Rails?")
```

## Web research (Anthropic)

```ruby
class WebResearchAgent < RailsAgents::Agent
  provider :anthropic
  model "claude-sonnet-4-20250514"
  description "Research topics using current web data. Cite sources."
  skills :web_search, :web_fetch
end

WebResearchAgent.run("What's new in Ruby on Rails?")
```

## Spreadsheet report (Anthropic)

```ruby
class SheetBuilderAgent < RailsAgents::Agent
  provider :anthropic
  model "claude-sonnet-4-20250514"
  description "Build a clear spreadsheet from the user's request."
  skills :xlsx
end

result = SheetBuilderAgent.run(
  "Create a 2x2 sample sales sheet for Q1",
  save_files_to: "tmp/sheets"
)

result.files.first.path  # => "tmp/sheets/...."
```

## Scoped tools (no auto-discovery)

When `app/agents/tools/` has tools for many agents:

```ruby
class DocAgent < RailsAgents::Agent
  provider :openai
  model "gpt-4o-mini"
  description "Answer questions using internal docs."
  discover_tools false
  tools "SearchDocs"
end
```

## Next

- [Playground app](/guide/playground) — try agents in the browser
- [Agents](/guide/agents) — full API
