# AGENTS.md

**Start here** when using Cursor, Claude Code, or another external coding agent with Rails Agent.

Full onboarding guide: **[docs/AGENTS.md](docs/AGENTS.md)**

Quick start:

1. `bin/rails generate rails_agents:install` → open `/agents` and connect workspace  
2. `bin/rails generate rails_agents:agent my_agent --type knowledge --database`  
3. Attach BYOK credentials in cloud dashboard; reference as `credential: :company_openai` in `agent.rb`  
4. `bundle exec rails-agents sync my_agent` → test/deploy/monitor in `/agents`

Four taxonomy types: **Knowledge**, **Workflow**, **Operations**, **Monitoring**.

Capabilities: **Tools**, **Skills**, **Packages** (Skills.sh / APM / Smithery), **Connectors**, **Knowledge**, plus workspace **Library** reuse.

Run responses: prefer `result.output_text` (Markdown) and optional `result.output_data` — see [docs/AGENTS.md](docs/AGENTS.md#run-response-schema-integrate-into-product) and https://rails-agent.com/docs/run-response.
