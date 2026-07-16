import { defineConfig } from "vitepress";

const siteUrl = "https://tiny-bubble-company.github.io/rails-agents";
const base = process.env.DOCS_BASE || "/";
const description =
  "Dead-simple AI agents for Rails — cloud by default. Define agents in Ruby, prepaid Credits for durable Eve runtime on Vercel, Tool Bridge into your app. Fastest path to production.";

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
          "rails agents, ruby ai agents, rails llm, openai rails, anthropic rails, claude agents, gpt agents, ai agents ruby, llm tools rails, agent framework rails, rubyllm alternative, langchain ruby, openrouter rails, grok rails, ai workflow rails",
      },
    ],
    ["meta", { property: "og:type", content: "website" }],
    ["meta", { property: "og:site_name", content: "Rails Agents" }],
    ["meta", { property: "og:title", content: "Rails Agents — Dead-simple AI agents for Rails" }],
    ["meta", { property: "og:description", content: description }],
    ["meta", { property: "og:url", content: siteUrl }],
    ["meta", { property: "og:image", content: `${siteUrl}/og.png` }],
    ["meta", { name: "twitter:card", content: "summary_large_image" }],
    ["meta", { name: "twitter:title", content: "Rails Agents — Dead-simple AI agents for Rails" }],
    ["meta", { name: "twitter:description", content: description }],
    ["meta", { name: "twitter:image", content: `${siteUrl}/og.png` }],
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
      {
        text: "Community",
        link: "https://github.com/Tiny-Bubble-Company/rails-agents/discussions/1",
      },
      {
        text: "v0.1.0",
        items: [
          { text: "Changelog", link: "/guide/changelog" },
          { text: "Requirements", link: "/guide/requirements" },
          {
            text: "Rubygems",
            link: "https://rubygems.org/gems/rails-agent-stack",
          },
        ],
      },
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
