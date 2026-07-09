# Rails Agents sample app

Minimal Rails app for manually testing the gem during development.

## Setup

From the gem root:

```bash
bin/setup
```

Or manually:

```bash
bundle install
cd spec/dummy
bundle install
bin/rails db:prepare
```

## Run the playground

```bash
cd spec/dummy
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...   # for WebResearchAgent and SheetBuilderAgent
bin/rails server
```

Open **http://localhost:3000**

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

## What's included

| Agent | Tests |
|-------|-------|
| `HelloAgent` | OpenAI, basic `.run` |
| `LeadQualifier` | Custom tools (`SearchCrm`, `CreateCrmNote`) |
| `WebResearchAgent` | Anthropic `:web_search` skill |
| `SheetBuilderAgent` | Anthropic `:xlsx` skill + file download |

Edit agents in `app/agents/` and tools in `app/agents/tools/`.
