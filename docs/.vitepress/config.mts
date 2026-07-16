import { defineConfig } from "vitepress";

const siteUrl = process.env.DOCS_SITE_URL || "https://rails.meerkatagents.com";
const base = process.env.DOCS_BASE || "/";
const description =
  "The framework for building agents in Rails. Like Eve for Ruby apps — an agent is a directory, durable execution and hosted schedules included. Tool Bridge into your Rails app. Docs + Cloud for production agents.";

export default defineConfig({
  title: "Rails Agents",
  description,
  base,
  cleanUrls: true,
  lastUpdated: true,
  ignoreDeadLinks: true,
  appearance: "force-dark",
  sitemap: {
    hostname: siteUrl,
  },

  head: [
    ["link", { rel: "icon", href: `${base}favicon.svg` }],
    ["meta", { name: "theme-color", content: "#0c0a09" }],
    ["meta", { name: "color-scheme", content: "dark" }],
    [
      "meta",
      {
        name: "keywords",
        content:
          "rails agents, durable agents rails, eve for rails, ruby ai agents, rails llm agents, rubyllm alternative, langchain ruby, tool bridge rails, hosted cron agents, openai rails, anthropic rails, claude agents, gpt agents, agent framework rails",
      },
    ],
    ["meta", { property: "og:type", content: "website" }],
    ["meta", { property: "og:site_name", content: "Rails Agents" }],
    ["meta", { property: "og:title", content: "Rails Agents — The framework for building agents in Rails" }],
    ["meta", { property: "og:description", content: description }],
    ["meta", { property: "og:url", content: siteUrl }],
    ["meta", { property: "og:image", content: `${siteUrl}/images/runtime-architecture.svg` }],
    ["meta", { name: "twitter:card", content: "summary_large_image" }],
    ["meta", { name: "twitter:title", content: "Rails Agents — The framework for building agents in Rails" }],
    ["meta", { name: "twitter:description", content: description }],
    ["meta", { name: "twitter:image", content: `${siteUrl}/images/agent-directory.svg` }],
    [
      "script",
      {
        type: "application/ld+json",
      },
      JSON.stringify({
        "@context": "https://schema.org",
        "@type": "SoftwareApplication",
        name: "Rails Agents",
        applicationCategory: "DeveloperApplication",
        operatingSystem: "Any",
        description,
        url: siteUrl,
        downloadUrl: "https://rubygems.org/gems/rails-agent-stack",
        codeRepository: "https://github.com/Tiny-Bubble-Company/rails-agents",
        license: "https://opensource.org/licenses/MIT",
        author: {
          "@type": "Organization",
          name: "Tiny Bubble Company",
          url: "https://github.com/Tiny-Bubble-Company",
        },
        offers: {
          "@type": "Offer",
          price: "0",
          priceCurrency: "USD",
        },
      }),
    ],
  ],

  themeConfig: {
    logo: { src: "/logo-dark.svg", alt: "Rails Agents" },
    siteTitle: "Rails Agents",
    nav: [
      { text: "Guide", link: "/guide/getting-started" },
      { text: "Agents", link: "/guide/agents" },
      { text: "Tools", link: "/guide/tools" },
      { text: "Skills", link: "/guide/skills" },
      { text: "Changelog", link: "/guide/changelog" },
    ],

    sidebar: [
      {
        text: "Introduction",
        items: [
          { text: "Why Rails Agents", link: "/guide/why" },
          { text: "Getting Started", link: "/guide/getting-started" },
          { text: "Billing", link: "/guide/billing" },
          { text: "Community", link: "/guide/community" },
        ],
      },
      {
        text: "Core",
        items: [
          { text: "Agents", link: "/guide/agents" },
          { text: "Tools", link: "/guide/tools" },
          { text: "Skills", link: "/guide/skills" },
          { text: "Configuration", link: "/guide/configuration" },
        ],
      },
      {
        text: "Recipes",
        items: [
          { text: "Common patterns", link: "/guide/recipes" },
          { text: "Playground app", link: "/guide/playground" },
        ],
      },
      {
        text: "Reference",
        items: [
          { text: "Requirements", link: "/guide/requirements" },
          { text: "Changelog", link: "/guide/changelog" },
        ],
      },
    ],

    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/Tiny-Bubble-Company/rails-agents",
      },
    ],

    search: {
      provider: "local",
    },

    editLink: {
      pattern:
        "https://github.com/Tiny-Bubble-Company/rails-agents/edit/main/docs/:path",
      text: "Edit this page",
    },

    footer: {
      message: "Released under the MIT License by Tiny Bubble Company.",
      copyright: "Agents for Rails — speed to production, not framework noise.",
    },

    outline: {
      level: [2, 3],
    },
  },
});
