# Billing

Rails Agents Cloud is **prepaid**. Tiny Bubble does not fund free hosted LLM or sandbox usage.

## Free

- Sign up, create API keys, define agents, use the dashboard UI
- Optional **BYOK** in sandbox (your OpenAI/Anthropic key)

## Paid (required for hosted `.run`)

1. **Credits** — minimum **$10** top-up before any hosted run  
2. Usage debits Credits at **Vercel infra cost × (1 + margin)**  
3. **Production** — subscribe, then promote; use `rak_live_…` keys  

If Credits are empty or missing, the API returns `402` and the gem raises:

```ruby
RailsAgents::PaymentRequired
# message + checkout_url
```

## Full policy

See the canonical doc: [PRICING.md](https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/PRICING.md).

## Next

- [Getting Started](/guide/getting-started)
- [Configuration](/guide/configuration)
