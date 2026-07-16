# Weather brief — reference agent

```bash
mkdir -p app/agents
cp -R examples/weather app/agents/
# or: rails-agents new weather
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
RailsAgents["weather"].run("What's the weather vibe in Berlin?")
```
