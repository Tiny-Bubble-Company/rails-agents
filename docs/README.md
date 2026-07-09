# Rails Agents Docs

Documentation site for [Rails Agents](https://github.com/Tiny-Bubble-Company/rails-agents), built with [VitePress](https://vitepress.dev/).

**Live:** [https://tiny-bubble-company.github.io/rails-agents/](https://tiny-bubble-company.github.io/rails-agents/)

## Local development

```bash
cd docs
npm install
npm run dev
```

Open http://localhost:5173.

## Build

```bash
cd docs
npm run build
```

Output is written to `docs/.vitepress/dist`.

## Deploy

GitHub Pages deploys from `.github/workflows/docs.yml` on pushes to `main` that touch `docs/**`.
