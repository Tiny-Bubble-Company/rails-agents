# Changelog

All notable changes to `rails-agent-stack` will be documented in this file.

## [0.2.0] - Unreleased

### Changed

- Documentation-first onboarding (AGENTS.md); removed Kip / chat-authoring positioning.
- Four product-facing agent taxonomy types: Knowledge, Workflow, Operations, Monitoring.
- BYOK model DSL: `model :name, provider:, credential:` with cloud credential references.
- Generator `--type` and `--database` for database-connected Knowledge agents.
- Company subscription + pass-through usage + 1% service fee pricing model.
- Deprecated cloud pull bridge in embed UI; `rails-agents pull` retained for compatibility.

### Added

- `KnowledgeAgent`, `OperationsAgent`, and `MonitoringAgent` classes; the legacy output-focused class remains loadable for compatibility.
- `docs/AGENTS.md` canonical guide for external coding agents.

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
