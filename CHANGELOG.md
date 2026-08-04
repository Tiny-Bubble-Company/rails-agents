# Changelog

All notable changes to `rails-agent-stack` will be documented in this file.

## [0.2.2] - 2026-08-04

### Changed

- Preserve blank lines between paragraphs in the RubyGems description so Build /
  Test / Deploy / Monitor / providers render as separated sections on the gem page.

## [0.2.1] - 2026-08-04

### Changed

- Expanded RubyGems summary/description to cover the full Build → Test → Deploy →
  Monitor lifecycle and name supported BYOK providers (OpenAI, Anthropic, Google
  Gemini, OpenRouter, xAI, Groq, Mistral AI, DeepSeek, Together AI, Fireworks AI,
  Perplexity, Cerebras, Hugging Face, and custom OpenAI-compatible providers).

## [0.2.0] - 2026-08-03

### Changed

- Documentation-first onboarding (AGENTS.md); removed Kip / chat-authoring positioning.
- Four product-facing agent taxonomy types: Knowledge, Workflow, Operations, Monitoring.
- BYOK model DSL: `model :name, provider:, credential:` with cloud credential references.
- Generator `--type` and `--database` for database-connected Knowledge agents.
- Company subscription + pass-through usage + 1% service fee pricing model.
- Deprecated cloud pull bridge in embed UI; `rails-agents pull` retained for compatibility.
- **Rails support widened to 6.1+** (was 7.0+). Compatibility shims for redirects, CSRF,
  Zeitwerk ignore, `module_parent_name`, and database configs.
- Gem authors attributed to Tiny Bubble Company (`support@rails-agent.com`).

### Added

- `KnowledgeAgent`, `OperationsAgent`, and `MonitoringAgent` classes; the legacy output-focused class remains loadable for compatibility.
- `docs/AGENTS.md` canonical guide for external coding agents.
- `docs/RAILS_SUPPORT.md` — supported versions and upgrade/sidecar guidance for Rails 3–5 apps.
- `RailsAgents::Compat` helpers for cross-version engine behavior.

## [0.1.1] - 2026-08-02

### Changed

- Depend on published `open-wire` (`~> 0.1`) from RubyGems instead of a local path.
- Re-release after yanked `0.1.0` on RubyGems.

## [0.1.0] - 2026-07-18

### Added

- Initial release of the `rails-agent-stack` gem.
- Mountable Rails Engine at `/agents` with cloud dashboard proxy UI.
- `RailsAgents::Base` DSL — model, memory, knowledge, tools, skills, channels.
- Cloud HTTP client (`Net::HTTP`) for runs, deploys, channels, knowledge sync, logs, traces, evals.
- Thor CLI (`rails-agents`) — install, new, run, deploy, logs, traces, evals.
- Generators — `rails_agents:install`, `rails_agents:agent`.
- Configuration block with ENV defaults.
- Example support agent under `examples/support/`.
- RSpec coverage for Base, Client, and Configuration.
