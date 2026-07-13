# Usage insights playbook

Rubygems download counts **do not** reveal use cases. Most early downloads for a new gem are mirrors, CI scrapers, and bots.

## Signals that matter (ranked)

1. **Show and tell replies** — https://github.com/Tiny-Bubble-Company/rails-agents/discussions/1
2. **Use-case issues** — label `use-case`
3. **Feature requests tagged with a category** — template asks for use-case category
4. **GitHub clones / unique cloners** — Insights → Traffic
5. **Public code search** (weekly):
   ```bash
   gh search code '"rails-agent-stack"'
   gh search code 'RailsAgents::Agent'
   ```
6. Rubygems downloads — treat as vanity / distribution reach only

## Cadence

| When | Do |
|------|----|
| Weekly | Skim Discussions + `use-case` issues; note themes in a private doc |
| Weekly | Run the two `gh search code` commands above |
| Monthly | Post a short Announcements update: top friction + next release focus |
| After each release | Ask in Show and tell: “Did this unblock you?” |

## Outreach that creates signal

Downloads alone will not produce replies. Drive people to Discussion #1:

- Soft CTA in README / docs (already added)
- Reply to anyone who stars / forks / opens an issue and ask one question: “What agent are you building?”
- Post in Ruby / Rails communities with a link to Show and tell (not just “star the repo”)
- When someone DMs or emails — log a one-liner use case into Discussion #1 yourself (with permission)

## What not to do (yet)

- Phone-home / telemetry in the gem — high trust cost for little gain at this stage
- Optimizing features from download count alone

## Optional later

If Show and tell stays empty after real outreach, consider a 60-second Typeform linked from the docs footer — still opt-in, no gem telemetry.
