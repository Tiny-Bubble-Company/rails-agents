# Agents

Your agent is a directory. Same idea as Eve: **`instructions.md` is a complete agent.**

```bash
rails-agents new weather
rails-agents test weather
rails-agents deploy weather
```

```text
app/agents/weather/          # complete agent
  agent.json                 # the model it runs on
  instructions.md            # who it is
  tools/                     # what it can do
    fetch_forecast.rb
    post_summary.rb
  skills/                    # what it knows
    cities-and-units.md
  schedules/                 # when it acts on its own
    morning.yml
```

```ruby
RailsAgents["weather"].run("What's the weather in Berlin today?")
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
