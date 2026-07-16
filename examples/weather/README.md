# Weather brief — reference agent

```bash
mkdir -p app/agents
cp -R examples/weather app/agents/
# or: rails-agents new weather
rails-agents test weather
rails-agents deploy weather
```

```text
app/agents/weather/
  agent.json
  instructions.md
  schedules/morning.yml
```

```ruby
RailsAgents["weather"].run("What's the weather vibe in Berlin?")
```
