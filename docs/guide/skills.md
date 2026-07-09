# Skills

**Skills** are built-in capabilities (web search, spreadsheets, etc.) provided by the gem. **Tools** are your app code.

```ruby
class ResearchAgent < RailsAgents::Agent
  provider :anthropic
  model "claude-sonnet-4-20250514"
  description "Research topics using current web data and internal docs."
  skills :web_search, :web_fetch
  tools "SearchInternalDocs"
end
```

## Built-in skills

| Skill | What it does | Anthropic | OpenAI / OpenRouter / Grok |
|-------|--------------|-----------|----------------------------|
| `:web_search` | Search the web | Native server tool | Portable Ruby tool |
| `:web_fetch` | Read a URL | Native server tool | Portable Ruby tool |
| `:code_execution` | Run code on Anthropic servers | Native | Anthropic only |
| `:memory` | Persistent memory | Native | Anthropic only |
| `:pptx` | Create/edit PowerPoint | Anthropic Agent Skill | Anthropic only |
| `:xlsx` | Create/edit Excel | Anthropic Agent Skill | Anthropic only |
| `:docx` | Create/edit Word | Anthropic Agent Skill | Anthropic only |
| `:pdf` | Generate PDFs | Anthropic Agent Skill | Anthropic only |

On **Anthropic**, skills run on their servers — the gem passes the right API payloads (including document skills and `code_execution` when needed).

On **other providers**, `:web_search` and `:web_fetch` use portable Ruby implementations so the same DSL works everywhere.

## Skill options

```ruby
skills :web_search, max_uses: 5, allowed_domains: ["wikipedia.org"]
# or
skills web_search: { max_uses: 5 }, :xlsx
```

## Document skills + file download

Document skills (`:pptx`, `:xlsx`, `:docx`, `:pdf`) run on Anthropic's servers. Generated files are **automatically downloaded** via the Files API:

```ruby
class ReportBuilder < RailsAgents::Agent
  provider :anthropic
  model "claude-sonnet-4-20250514"
  description "Build a quarterly sales spreadsheet with charts."
  skills :xlsx
end

result = ReportBuilder.run("Create Q1 sales report", save_files_to: "tmp/reports")
result.output                       # => "Created your spreadsheet..."
result.files.first.filename         # => "report.xlsx"
result.files.first.path             # => "tmp/reports/report.xlsx"
```

`:pptx`, `:xlsx`, `:docx`, and `:pdf` automatically enable `code_execution`, attach Anthropic's published skills, and include the required beta headers.

Configure download behavior in the initializer:

```ruby
RailsAgents.configure do |config|
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
  config.anthropic_auto_download_files = true  # default
  config.anthropic_files_directory = Rails.root.join("tmp/rails_agents/files")
end
```

## Custom Anthropic skills

Upload skills via the [Anthropic Skills API](https://platform.claude.com/docs/en/build-with-claude/skills-guide), then reference by ID:

```ruby
skills :web_search, "skill_01AbCdEfGhIjKlMnOpQrStUv"
```

## Next

- [Providers](/guide/providers) — which provider supports what
- [Configuration](/guide/configuration) — file download settings
- [Recipes](/guide/recipes) — research and report examples
