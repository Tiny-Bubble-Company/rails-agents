# Changelog

All notable changes to this project are documented in this file.

## [0.1.0] — 2026-07-09

First public release.

- `RailsAgents::Agent` — one class for every use case (`provider`, `model`, `description`, `tools`, `skills`)
- `RailsAgents::Tool` — app code as tools, auto-loaded from `app/agents/tools/`
- Skills: `:web_search`, `:web_fetch` (portable + Anthropic native); Anthropic `:code_execution`, `:memory`, `:pptx`, `:xlsx`, `:docx`, `:pdf`
- Providers: OpenAI, Anthropic, OpenRouter, Grok
- Install generator (`rails generate rails_agents:install`)
- Sample playground app in `spec/dummy/`
- Documentation site (VitePress) on GitHub Pages
- Fix: `Providers.build` no longer passes a nil API key that overrode config defaults
