<template>
  <div class="mkt">
    <section class="mkt-section">
      <p class="mkt-kicker">An agent is a directory</p>
      <h2 class="mkt-h2">This is a Rails Agents agent.</h2>
      <p class="mkt-lead">
        Each file describes one component — so at a glance the tree tells you who
        the agent is, what it can do, what it knows, and when it acts on its own.
        Same idea as Eve. Native to Rails.
      </p>
      <figure class="mkt-figure">
        <img
          src="/images/agent-directory.svg"
          alt="Directory tree for app/agents/accidental_damage_sync with annotated instructions, tools, skills, and schedules"
          width="920"
          height="640"
          loading="eager"
        />
        <figcaption>An Accidental Damage Cover → FTP sync agent, readable at a glance.</figcaption>
      </figure>
    </section>

    <section class="mkt-section">
      <p class="mkt-kicker">Create an agent in minutes</p>
      <h2 class="mkt-h2">Focus on what it does — not how it runs.</h2>
      <p class="mkt-lead">
        Production agents wait on people, call slow systems, and outlive a single
        request. Chat SDKs give you a loop. Rails Agents ships durability, schedules,
        and a Tool Bridge into your app — the plumbing every team rebuilds by hand.
      </p>
      <figure class="mkt-figure mkt-figure--dark">
        <img
          src="/images/cli-flow.svg"
          alt="Terminal showing rails-agents new, test, and deploy"
          width="920"
          height="280"
          loading="lazy"
        />
      </figure>
      <div class="mkt-code-grid">
        <div class="mkt-code-card">
          <p class="mkt-code-label">app/agents/…/instructions.md</p>
          <pre><code># Identity

You sync new Accidental Damage Cover
agreements to the insurer FTP.

Prefer Tool Bridge tools over guessing.
Never re-upload a synced agreement.</code></pre>
        </div>
        <div class="mkt-code-card">
          <p class="mkt-code-label">schedules/poll.yml</p>
          <pre><code>cron: "*/15 * * * *"
message: |
  Poll for new ADC agreements and
  upload via FTP. Idempotent.</code></pre>
        </div>
      </div>
    </section>

    <section class="mkt-section">
      <p class="mkt-kicker">Batteries included</p>
      <h2 class="mkt-h2">Everything a production agent needs.</h2>
      <p class="mkt-lead">
        Inspired by Eve’s production shape — durable sessions, sandboxed work,
        human-in-the-loop, schedules — delivered as gem + Cloud for Rails teams.
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
        API, cron, CLI, dashboard — on the right. You write the directory; Cloud
        runs the hard parts.
      </p>
      <figure class="mkt-figure">
        <img
          src="/images/runtime-architecture.svg"
          alt="Rails Agents Cloud runtime architecture with durable workflow, Tool Bridge, schedules, and surfaces"
          width="1100"
          height="720"
          loading="lazy"
        />
        <figcaption>
          Hosted at
          <a href="https://agents.meerkatagents.com">agents.meerkatagents.com</a>
          beside Meerkat on Hetzner.
        </figcaption>
      </figure>
    </section>

    <section class="mkt-section">
      <p class="mkt-kicker">Works natively with Rails</p>
      <h2 class="mkt-h2">Same app. Same deploy. Your tools stay home.</h2>
      <p class="mkt-lead">
        Install the gem, mount the Tool Bridge, keep DB/FTP/CRM credentials in
        Rails. The cloud agent calls back with HMAC — no second stack, no
        copying secrets into a Node repo.
      </p>
      <div class="mkt-code-grid">
        <div class="mkt-code-card">
          <p class="mkt-code-label">Gemfile</p>
          <pre><code>gem "rails-agent-stack"</code></pre>
        </div>
        <div class="mkt-code-card">
          <p class="mkt-code-label">Then</p>
          <pre><code>bin/rails g rails_agents:install
rails-agents new my_agent
rails-agents deploy my_agent</code></pre>
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
const batteries = [
  {
    title: "Durable execution",
    body: "Checkpointed runs on Rails Agents Cloud. Agents park between turns, survive deploys, and resume on delivery — not a fire-and-forget chat call.",
  },
  {
    title: "Hosted schedules",
    body: "schedules/poll.yml becomes cloud cron after deploy. Replace Render rake workers for jobs like ADC → insurer FTP.",
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
</script>
