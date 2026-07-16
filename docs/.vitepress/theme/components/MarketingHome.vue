<template>
  <div class="mkt">
    <section class="mkt-section">
      <p class="mkt-kicker">An agent is a directory</p>
      <h2 class="mkt-h2">This is a Rails Agents agent.</h2>
      <p class="mkt-lead">
        One folder. A few files. At a glance you see who it is, what it can do,
        what it knows, and when it runs — same idea as Eve, native to Rails.
      </p>

      <div class="mkt-dir" role="img" aria-label="Weather agent directory structure">
        <div class="mkt-dir-head">
          <span class="mkt-dir-path">app/agents/weather/</span>
          <span class="mkt-dir-badge">complete agent</span>
        </div>
        <ul class="mkt-dir-tree">
          <li v-for="row in tree" :key="row.name" :class="{ 'is-child': row.child }">
            <code class="mkt-dir-name">{{ row.name }}</code>
            <span class="mkt-dir-note">{{ row.note }}</span>
          </li>
        </ul>
        <p class="mkt-dir-caption">A weather agent, readable at a glance.</p>
      </div>
    </section>

    <section class="mkt-section">
      <p class="mkt-kicker">Create an agent in minutes</p>
      <h2 class="mkt-h2">Focus on what it does — not how it runs.</h2>
      <p class="mkt-lead">
        Three commands. Your <code>instructions.md</code> is the agent. Cloud
        handles durable runs, schedules, and the dashboard.
      </p>

      <div class="mkt-term" aria-label="CLI commands">
        <div class="mkt-term-bar">
          <span /><span /><span />
        </div>
        <pre class="mkt-term-body"><code><span class="mkt-term-prompt">$</span> rails-agents new weather
<span class="mkt-term-prompt">$</span> rails-agents test weather
<span class="mkt-term-prompt">$</span> rails-agents deploy weather
<span class="mkt-term-ok">→ Deployed — dashboard opens with status &amp; run logs</span></code></pre>
      </div>

      <div class="mkt-code-grid">
        <div class="mkt-code-card">
          <p class="mkt-code-label">app/agents/weather/instructions.md</p>
          <pre><code># Identity

You are a weather brief agent.
Fetch today's forecast for the user's
cities and post a short summary.

Prefer Tool Bridge tools over guessing.
Keep answers short and practical.</code></pre>
        </div>
        <div class="mkt-code-card">
          <p class="mkt-code-label">schedules/morning.yml</p>
          <pre><code>cron: "0 7 * * *"
timezone: UTC
message: |
  Fetch today's weather for configured
  cities and post the morning brief.</code></pre>
        </div>
      </div>
    </section>

    <section class="mkt-section">
      <p class="mkt-kicker">Batteries included</p>
      <h2 class="mkt-h2">Everything a production agent needs.</h2>
      <p class="mkt-lead">
        Durable sessions, schedules, Tool Bridge, human-in-the-loop — delivered
        as gem + Cloud for Rails teams.
      </p>
      <div class="mkt-batteries">
        <article v-for="item in batteries" :key="item.title" class="mkt-battery">
          <h3>{{ item.title }}</h3>
          <p>{{ item.body }}</p>
        </article>
      </div>
    </section>

    <section class="mkt-section">
      <p class="mkt-kicker">Architecture</p>
      <h2 class="mkt-h2">Runtime + surface — one picture.</h2>
      <p class="mkt-lead">
        Durable execution and Tool Bridge on the left. Where the agent shows up —
        API, cron, CLI, dashboard — on the right.
      </p>
      <div class="mkt-arch" aria-label="Rails Agents runtime and surface architecture">
        <div class="mkt-arch-col">
          <p class="mkt-arch-label">Runtime</p>
          <p class="mkt-arch-sub">Durable execution, state persistence, event streaming</p>
          <article v-for="item in runtime" :key="item.title" class="mkt-arch-card">
            <h3>{{ item.title }}</h3>
            <p>{{ item.body }}</p>
            <span v-if="item.tag" class="mkt-arch-tag">{{ item.tag }}</span>
          </article>
        </div>
        <div class="mkt-arch-col">
          <p class="mkt-arch-label">Surface</p>
          <p class="mkt-arch-sub">Where your agent gets surfaced</p>
          <article class="mkt-arch-card mkt-arch-card--surface">
            <h3>Where it runs</h3>
            <ul>
              <li v-for="s in surfaces" :key="s">{{ s }}</li>
            </ul>
          </article>
        </div>
      </div>
      <p class="mkt-arch-caption">
        Hosted at
        <a href="https://agents.meerkatagents.com">agents.meerkatagents.com</a>
      </p>
    </section>

    <section class="mkt-section">
      <p class="mkt-kicker">Works natively with Rails</p>
      <h2 class="mkt-h2">Same app. Same deploy. Your tools stay home.</h2>
      <p class="mkt-lead">
        Install the gem, mount the Tool Bridge, keep API keys and DB access in
        Rails. The cloud agent calls back with HMAC — no second stack.
      </p>
      <div class="mkt-code-grid">
        <div class="mkt-code-card">
          <p class="mkt-code-label">Gemfile</p>
          <pre><code>gem "rails-agent-stack"</code></pre>
        </div>
        <div class="mkt-code-card">
          <p class="mkt-code-label">Then</p>
          <pre><code>bin/rails g rails_agents:install
rails-agents new weather
rails-agents deploy weather</code></pre>
        </div>
      </div>
    </section>

    <section class="mkt-section mkt-section--compare">
      <p class="mkt-kicker">Not another chat gem</p>
      <h2 class="mkt-h2">RubyLLM is a toolkit. This is an agent product path.</h2>
      <div class="mkt-compare">
        <div>
          <h3>Use RubyLLM when…</h3>
          <p>You want a multimodal LLM SDK, embeddings, and chat persistence you host yourself.</p>
        </div>
        <div>
          <h3>Use Rails Agents when…</h3>
          <p>You need Eve-style durable agents in Rails — directory in, deploy out, schedules and Tool Bridge included.</p>
        </div>
      </div>
    </section>

    <section class="mkt-cta">
      <h2>Build your first durable agent today.</h2>
      <p>Docs, gem, and Cloud — one path from instructions.md to production.</p>
      <div class="mkt-cta-actions">
        <a class="mkt-btn mkt-btn--brand" href="/guide/getting-started">Get started</a>
        <a class="mkt-btn mkt-btn--alt" href="https://agents.meerkatagents.com">Open Cloud</a>
        <a class="mkt-btn mkt-btn--alt" href="https://github.com/Tiny-Bubble-Company/rails-agents">GitHub</a>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
const tree = [
  { name: "agent.json", note: "# the model it runs on" },
  { name: "instructions.md", note: "# who it is" },
  { name: "tools/", note: "# what it can do" },
  { name: "fetch_forecast.rb", note: "", child: true },
  { name: "post_summary.rb", note: "", child: true },
  { name: "skills/", note: "# what it knows" },
  { name: "cities-and-units.md", note: "", child: true },
  { name: "schedules/", note: "# when it acts on its own" },
  { name: "morning.yml", note: "", child: true },
];

const batteries = [
  {
    title: "Durable execution",
    body: "Checkpointed runs on Rails Agents Cloud. Agents park between turns, survive deploys, and resume on delivery.",
  },
  {
    title: "Hosted schedules",
    body: "schedules/morning.yml becomes cloud cron after deploy — no Render workers for your daily weather brief.",
  },
  {
    title: "Tool Bridge",
    body: "Signed callbacks into your Rails models, jobs, and services. Secrets never leave your app process.",
  },
  {
    title: "Human-in-the-loop",
    body: "Approval-sensitive tools can park a session until a human confirms — then resume from the same durable run.",
  },
  {
    title: "Dashboard & logs",
    body: "Status, environment, last run, and log lines at agents.meerkatagents.com after rails-agents deploy.",
  },
  {
    title: "Honest billing",
    body: "Free to sign up and define agents. Prepaid Credits before hosted runs. No pretend “free LLM” tokens.",
  },
];

const runtime = [
  {
    title: "Durable workflow",
    body: "Checkpointed steps, park between messages, resume on delivery.",
    tag: "Rails Agents Cloud",
  },
  {
    title: "Model runtime",
    body: "Model calls, streaming, prepaid Credits metering.",
    tag: "AI Gateway",
  },
  {
    title: "Tool Bridge",
    body: "Signed callbacks into your Rails app. Secrets stay in Rails.",
    tag: "HMAC /rails_agents",
  },
  {
    title: "Hosted schedules",
    body: "Cron from schedules/morning.yml — no Render workers.",
    tag: "Cron",
  },
  {
    title: "Tools & subagents",
    body: "Rails tools, child agents, optional skills.",
  },
];

const surfaces = [
  "API · Agent.run",
  "Hosted cron",
  "CLI · rails-agents deploy",
  "Dashboard · runs & logs",
  "Tool Bridge · Rails",
  "DB / weather APIs",
  "Sandbox keys",
  "Production keys",
  "Slack / web (roadmap)",
  "Eval suites (roadmap)",
];
</script>
