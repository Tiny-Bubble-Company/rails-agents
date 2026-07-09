# Playground app

A minimal Rails app at `spec/dummy/` for trying agents in a browser or console.

## Setup

From the gem root:

```bash
bin/setup
cd spec/dummy
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...   # WebResearchAgent, SheetBuilderAgent
bin/rails server
```

Open **http://localhost:3000** — pick an agent, send input, inspect the result.

## Included agents

| Agent | What it demonstrates |
|-------|----------------------|
| `HelloAgent` | OpenAI, basic `.run` |
| `LeadQualifier` | Custom tools |
| `WebResearchAgent` | Anthropic `:web_search` skill |
| `SheetBuilderAgent` | Anthropic `:xlsx` skill + file download |

## Console

```bash
cd spec/dummy
bin/rails console
```

```ruby
HelloAgent.run("Say hello")
LeadQualifier.run("New lead from Acme Corp — 50 employees, asked about enterprise pricing")
WebResearchAgent.run("What's new in Ruby on Rails?")
SheetBuilderAgent.run("2x2 sample sheet", save_files_to: "tmp/sheets")
```

Edit agents in `app/agents/` and tools in `app/agents/tools/`.

::: warning Live API calls
Running agents in the playground calls live APIs and can take several seconds. The page itself loads instantly; only the "Run agent" action hits the network.
:::

## Tests (no API keys)

From the gem root, tests use fakes and WebMock — fast, no network:

```bash
bundle install
bin/test
```
