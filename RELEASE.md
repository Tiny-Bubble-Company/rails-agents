# Release checklist

## 0.2.0

```bash
bundle exec rspec
gem build rails-agent-stack.gemspec
gem push rails-agent-stack-0.2.0.gem
git tag -a v0.2.0 -m "rails-agent-stack 0.2.0"
git push origin v0.2.0
```

Confirm: https://rubygems.org/gems/rails-agent-stack  
Docs: https://rails.meerkatagents.com
