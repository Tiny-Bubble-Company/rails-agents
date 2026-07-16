# Agents

Your agent is a directory. Same idea as Eve: **`instructions.md` is a complete agent.**

```bash
rails-agents new accidental_damage_sync
rails-agents test accidental_damage_sync
rails-agents deploy accidental_damage_sync
```

```text
app/agents/accidental_damage_sync/
  instructions.md      # required — complete agent
  agent.json           # model + triggers
  schedules/poll.yml   # hosted cron after deploy
  tools/               # optional
```

```ruby
RailsAgents["accidental_damage_sync"].run("Poll new ADC agreements")
```

That:

1. Syncs the directory to Cloud  
2. Runs on the hosted runtime (Credits required)  
3. Returns a `Result` — dashboard shows status + logs after deploy

## instructions.md

```markdown
# Identity

You are an expert weather assistant.
You can fetch the weather for any city in the world.
```

## Optional agent.json

```json
{ "model": "anthropic/claude-sonnet-4" }
```

## Class agents (still supported)

```ruby
class SupportAgent < RailsAgents::Agent
  model "anthropic/claude-sonnet-4"
  description "Answers customer questions."
end

SupportAgent.run("How do I reset my password?")
```

Class agents sync their `description` as instructions before run. Prefer the directory form for new agents.

## Credits

Hosted `.run` requires prepaid Credits (min $10). Unfunded → `RailsAgents::PaymentRequired`. See [Billing](/guide/billing).
