# Changelog

All notable changes to `rails-agent-stack` will be documented in this file.

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
