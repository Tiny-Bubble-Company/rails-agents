# Providers

Rails Agents supports four providers behind one DSL. Pick a provider and model on each agent.

| Provider | API key config | Example model |
|----------|----------------|---------------|
| `:openai` | `openai_api_key` | `"gpt-4o-mini"` |
| `:anthropic` | `anthropic_api_key` | `"claude-sonnet-4-20250514"` |
| `:openrouter` | `openrouter_api_key` | `"meta-llama/llama-3.3-70b-instruct:free"` |
| `:grok` | `grok_api_key` | `"grok-2-latest"` |

```ruby
class SupportAgent < RailsAgents::Agent
  provider :openai
  model "gpt-4o-mini"
  description "Answers customer questions."
end
```

## OpenAI

Standard Chat Completions-compatible API. Good default for most agents.

```ruby
provider :openai
model "gpt-4o-mini"
```

Set `OPENAI_API_KEY` or `config.openai_api_key`.

## Anthropic

Best when you need native skills: web search/fetch, code execution, memory, and document skills (`:xlsx`, `:pptx`, `:docx`, `:pdf`).

```ruby
provider :anthropic
model "claude-sonnet-4-20250514"
skills :web_search, :xlsx
```

Set `ANTHROPIC_API_KEY` or `config.anthropic_api_key`.

## OpenRouter

One API key for hundreds of open-source and commercial models — useful for trying agents without committing to a single vendor.

```ruby
provider :openrouter
model "meta-llama/llama-3.3-70b-instruct:free"
```

Set `OPENROUTER_API_KEY` or `config.openrouter_api_key`.

## Grok (xAI)

```ruby
provider :grok
model "grok-2-latest"
```

Set `XAI_API_KEY` (or `GROK_API_KEY`) or `config.grok_api_key`.

## Skill support by provider

| Skill | Anthropic | Others |
|-------|-----------|--------|
| `:web_search`, `:web_fetch` | Native | Portable Ruby tools |
| `:code_execution`, `:memory` | Native | — |
| `:pptx`, `:xlsx`, `:docx`, `:pdf` | Native | — |

See [Skills](/guide/skills) for full details.

## Default provider

If an agent omits `provider`, the configured default is used (`:openai` unless you change it):

```ruby
RailsAgents.configure do |config|
  config.default_provider = :anthropic
end
```

You still must set `model` on each agent.

## Next

- [Configuration](/guide/configuration)
- [Skills](/guide/skills)
