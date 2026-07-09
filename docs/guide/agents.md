# Agents

`RailsAgents::Agent` is the only agent class. Each use case is a new subclass with its own `description` — not a new framework concept.

```ruby
class EmailDrafter < RailsAgents::Agent
  provider :anthropic
  model "claude-sonnet-4-20250514"
  description "Draft short, professional follow-up emails from bullet points."
end

class LeadQualifier < RailsAgents::Agent
  provider :openrouter
  model "meta-llama/llama-3.3-70b-instruct:free"
  description "Qualify inbound leads and create CRM notes for promising ones."
  tools "SearchCrm", "CreateCrmNote"
end
```

## Required declarations

| Declaration | Purpose |
|-------------|---------|
| `provider` | `:openai`, `:anthropic`, `:openrouter`, or `:grok` |
| `model` | Model id for that provider (required on each agent) |
| `description` | What the agent does — becomes the system instructions |

## Optional declarations

| Declaration | Purpose |
|-------------|---------|
| `tools` | Tool class names or constants the agent may call |
| `skills` | Built-in capabilities (`:web_search`, `:xlsx`, …) |
| `max_turns` | Cap on tool-loop turns (default from the runner) |
| `discover_tools` | When `false`, only declared tools are available |

## Run API

All equivalent:

```ruby
SupportAgent.run("question")
SupportAgent.ask("question")
SupportAgent.call("question")
```

### Options

```ruby
SupportAgent.run(
  "Create Q1 sales report",
  save_files_to: "tmp/reports",  # write downloaded files to disk
  parse_json: false,             # parse output as JSON when true
  # any extra kwargs become context for a Proc description
)
```

### Dynamic descriptions

Pass a block (or Proc) when instructions depend on runtime context:

```ruby
class ContextualAgent < RailsAgents::Agent
  provider :openai
  model "gpt-4o-mini"
  description do |ctx|
    "Help #{ctx[:user_name]} with their #{ctx[:plan]} plan."
  end
end

ContextualAgent.run("What can I upgrade to?", user_name: "Ada", plan: "starter")
```

## Result object

```ruby
result = SupportAgent.run("How do I reset my password?")

result.output    # agent's text reply
result.success   # true/false
result.error     # error message when success is false
result.files     # generated files (Anthropic document skills)
result.messages  # conversation messages
result.usage     # token usage
```

Pass `save_files_to:` to write downloaded files to disk:

```ruby
ReportBuilder.run("Create Q1 sales report", save_files_to: "tmp/reports")
```

## Tool discovery

By default, tools in `app/agents/tools/` are auto-discovered and available to every agent.

When that directory holds tools for multiple agents, turn discovery off and declare explicitly:

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

- [Tools](/guide/tools) — let the model call your Ruby code
- [Skills](/guide/skills) — built-in capabilities
- [Providers](/guide/providers) — OpenAI, Anthropic, OpenRouter, Grok
