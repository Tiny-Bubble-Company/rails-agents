# Configuration

API keys live in the initializer. Models live on each agent.

```ruby
# config/initializers/rails_agents.rb
RailsAgents.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
  config.openrouter_api_key = ENV["OPENROUTER_API_KEY"]
  config.grok_api_key = ENV["XAI_API_KEY"]

  # Optional
  config.default_provider = :openai
  config.anthropic_auto_download_files = true
  config.anthropic_files_directory = Rails.root.join("tmp/rails_agents/files")
end
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `openai_api_key` | `ENV["OPENAI_API_KEY"]` | OpenAI API key |
| `anthropic_api_key` | `ENV["ANTHROPIC_API_KEY"]` | Anthropic API key |
| `openrouter_api_key` | `ENV["OPENROUTER_API_KEY"]` | OpenRouter API key |
| `grok_api_key` | `ENV["XAI_API_KEY"]` or `ENV["GROK_API_KEY"]` | xAI / Grok API key |
| `default_provider` | `:openai` | Used when an agent omits `provider` |
| `anthropic_auto_download_files` | `true` | Auto-download files from Anthropic document skills |
| `anthropic_files_directory` | `tmp/rails_agents/files` | Where downloaded files are stored |

## Environment variables

You can skip the initializer fields and rely on env vars alone — the defaults already read them. The generator still creates the initializer so keys are visible and easy to override.

## Install generator

```bash
bin/rails generate rails_agents:install
```

Creates:

- `config/initializers/rails_agents.rb`
- `app/agents/`
- `app/agents/tools/`

## Next

- [Getting Started](/guide/getting-started)
- [Providers](/guide/providers)
