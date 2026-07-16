# Compiler: Ruby agent tree → Eve `agent/`

## Input (Rails app)

```text
app/agents/
  lead_qualifier/
    agent.rb
    instructions.md          # preferred
    tools/
      search_crm.rb
    skills/
      enterprise.md
    subagents/
      researcher/
        agent.rb
        instructions.md
```

## Output (Eve artifact)

```text
agent/
  agent.ts                   # model + limits from agent.rb
  instructions.md            # copied / rendered from description
  tools/
    search_crm.ts            # Tool Bridge shim (not Ruby logic)
  skills/
    enterprise.md
  subagents/
    researcher/
      agent.ts
      instructions.md
  channels/
    eve.ts                   # standard HTTP channel + our auth
```

## Mapping rules

| Ruby | Eve |
|------|-----|
| Folder name `lead_qualifier` | Agent id / sync key |
| `model "..."` | `defineAgent({ model })` gateway id |
| `instructions.md` or `description` | `instructions.md` |
| `tools/foo_bar.rb` → tool `foo_bar` | `tools/foo_bar.ts` bridge shim |
| `param :x, :string` | Zod `z.object({ x: z.string() })` |
| `skills/*.md` | copied |
| Subagent folders | nested `subagents/<id>/` |

## Sync API (control plane)

```http
PUT /v1/apps/:app_id/agents/:agent_id
Authorization: Bearer rak_sandbox_...
Content-Type: application/json
```

Body: serialized manifest (files as base64 or multipart). Creates a new **artifact version**; sandbox sessions use `latest` unless pinned.

## Non-goals for v1 compiler

- Compiling arbitrary Ruby into sandbox JS
- Customer-authored Eve channels (we inject the standard channel)
- Local `eve build` on the developer machine
