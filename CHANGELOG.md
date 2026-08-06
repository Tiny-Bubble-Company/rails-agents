# Changelog

All notable changes to `rails-agent-stack` will be documented in this file.

## [0.2.9] - 2026-08-06

### Changed

- New agents default to `openrouter/free` via `provider: :rails_agent` for
  free sandbox testing (knowledge + workflow generators).

## [0.2.8] - 2026-08-05

### Changed

- Default Knowledge agent `prompt.md` uses the customer-support Trigger /
  Workflow / Guidelines template.

## [0.2.7] - 2026-08-05

### Fixed

- Include `database_discovery` / `database_query` in the gem package (0.2.6
  omitted them because the gem was built before those files were committed).

## [0.2.6] - 2026-08-05

### Added

- `rails_agents:install` discovers `database.yml` / `mongoid.yml` and writes
  `config/rails_agents_database.yml`.
- New agents attach full-database knowledge + `sql_query` by default
  (`--no-database` to skip). Detach anytime in Knowledge.
- Tool Bridge: dialect-aware SQL limits + reserved `mongo_query` for Mongoid.
- Schema endpoint refreshes discovery when inspected from `/agents`.

## [0.2.5] - 2026-08-05

### Added

- Tool Bridge reserved `sql_query` / `query_database` — read-only SELECT against
  the Rails DB without a hand-written per-table tool.

## [0.2.4] - 2026-08-05

### Changed

- Shared capabilities live under `app/agents/shared/` (one tree with agents).
  Fresh installs no longer create sibling `app/agents_library/`.
- `imports.yml` prefers `from: shared/...`; legacy `from: library/...` and
  existing `app/agents_library/` installs still resolve.
- Agent generator rejects reserved slugs `shared` and `library`.

## [0.2.3] - 2026-08-05

### Fixed

- Signup/sign-in OTP "Use a different email" now clears the pending auth session
  so the email form is shown again (`?change_email=1`).
- Knowledge `--database` generator writes `knowledge/sources/rails_database.yml`
  as connected (no perpetual pending-snapshot flag).

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
