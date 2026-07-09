# Release checklist

Steps to publish `rails_agents` **0.1.0** to RubyGems and keep docs live.

## Prerequisites

1. RubyGems account with MFA enabled (gemspec sets `rubygems_mfa_required`)
2. API key from https://rubygems.org/profile/api_keys
3. Push access to `Tiny-Bubble-Company/rails-agents`

## 1. Verify locally

```bash
bundle exec rspec
cd docs && npm ci && npm run build && cd ..
gem build rails_agents.gemspec
```

## 2. Tag the release

```bash
git tag -a v0.1.0 -m "rails_agents 0.1.0"
git push origin v0.1.0
```

## 3. Publish the gem

```bash
gem push rails_agents-0.1.0.gem
```

Confirm at https://rubygems.org/gems/rails_agents

## 4. Confirm docs

Docs deploy automatically via GitHub Pages when `docs/**` changes land on `main`.

Live site: https://tiny-bubble-company.github.io/rails-agents/

## 5. GitHub release (optional)

```bash
gh release create v0.1.0 --title "v0.1.0" --notes-file CHANGELOG.md
```

## After publish

```bash
gem install rails_agents
# or
bundle add rails_agents
```
