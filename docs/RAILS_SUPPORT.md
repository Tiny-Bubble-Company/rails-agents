# Rails version support

## Supported

| Rails | Status |
|-------|--------|
| **8.x** | Fully supported |
| **7.x** | Fully supported |
| **6.1** | Supported (compatibility shims) |
| 6.0 | Best-effort (upgrade to 6.1+ recommended) |
| 5.x and older | **Not supported** — see below |

| Ruby | Status |
|------|--------|
| **3.2+** | Required |
| 3.1 and older | Not supported (open-wire and modern MRI tooling require 3.2+) |

`rails-agent-stack` is a mountable Rails engine with Zeitwerk-aware installers,
cloud sync, and channel webhooks. Those APIs exist from Rails 6.1 onward.

## Why not Rails 3–5?

Apps from ~2009 often run Rails 3–5 on Ruby 1.8–2.7. This gem targets **Ruby 3.2+**,
which those stacks never ran. Supporting Rails 3 would mean a separate legacy
product (different gem, different Ruby), not a shim inside this engine.

## Older apps (Rails 3–5): two practical paths

### 1. Upgrade the host app (recommended)

Bring the app to **Rails 6.1+ / Ruby 3.2+** (or Rails 7/8), then:

```ruby
gem "rails-agent-stack", "~> 0.2"
```

```bash
bundle install
bin/rails generate rails_agents:install
```

### 2. Sidecar modern Rails app

Keep the legacy app as-is. Create a small Rails 7/8 app (same database, or
API/DB views into the legacy data), install `rails-agent-stack` there, and expose
agents via channels/API. The legacy app stays on its old Rails; the agent
runtime stays modern.

## Checking your version

```bash
bin/rails runner 'puts "Rails #{Rails.version} / Ruby #{RUBY_VERSION}"'
```

Need help choosing a path? Email [kannan@rails-agent.com](mailto:kannan@rails-agent.com).
