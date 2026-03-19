# ShopSmart — E-Commerce Product Catalog

A full-stack e-commerce product browsing app built with **React** (Vite) and **Express**, demonstrating modern DevOps practices including CI/CD, automated testing, linting, and dependency management.

---

## Architecture

```
shopsmart/
├── client/          # React + Vite frontend
│   ├── src/
│   │   ├── components/   # Navbar, HeroSection, ProductsPage, ProductCard
│   │   ├── data/         # Static product data (fallback)
│   │   └── App.jsx       # Root component
│   └── e2e/              # Playwright end-to-end tests
├── server/          # Express.js backend API
│   ├── src/
│   │   ├── app.js        # Routes & middleware
│   │   └── index.js      # Server entry point
│   └── tests/            # Jest + Supertest backend tests
├── .github/
│   ├── workflows/        # CI/CD pipelines (ci.yml, test.yml, deploy.yaml)
│   └── dependabot.yml    # Automated dependency updates
└── run.sh           # Idempotent setup & run script
```

**Frontend** → React SPA served by Vite; fetches product data from the backend API (`/api/products`), with static JSON as a fallback.

**Backend** → Express REST API exposing `/api/products`, `/api/products/search`, and `/api/health` endpoints. Uses in-memory data for simplicity.

**Communication** → The Vite dev server proxies `/api` requests to the Express backend on port 5001, eliminating CORS issues during development.

---

## Workflow & CI/CD

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | push / PR on all branches | Lint → Test → Build (frontend & backend), integration smoke test |
| `test.yml` | push / PR on `main` | Install → Lint → Format check → Unit tests → Build → E2E (Playwright) |
| `deploy.yaml` | push to `main` | Build & deploy frontend to GitHub Pages |

All pipelines run on every **push** and **pull request**, ensuring code quality before merge.

### PR Checks

Pull requests trigger **ESLint** and **Prettier** checks. The pipeline fails if code quality standards are not met, enforcing consistent style across contributions.

### Dependabot

`dependabot.yml` is configured to check for outdated npm packages (both `client/` and `server/`) and GitHub Actions versions on a **weekly** schedule, automatically opening PRs for updates.

---

## Design Decisions

1. **Monorepo structure** — Client and server live together for simpler CI and a single `run.sh` entry point.
2. **Static data fallback** — The frontend ships with a local copy of product data so the UI works even if the backend is unreachable (e.g., GitHub Pages deployment).
3. **Vite proxy** — Configured in `vite.config.js` to forward `/api` calls to the Express server, avoiding CORS configuration during development.
4. **Idempotent scripts** — `run.sh` uses conditional checks (`-d`, `-nt`) to skip unnecessary installs and is safe to run repeatedly.
5. **Layered testing** — Unit tests (Vitest/Jest) → Integration tests (Supertest + component mocks) → E2E tests (Playwright) provide confidence at every level.

---

## Testing Strategy

| Layer | Tool | Scope |
|---|---|---|
| **Unit** | Vitest + Testing Library | Individual React components (Navbar, HeroSection, ProductCard) |
| **Unit** | Jest + Supertest | Backend API endpoints (`/api/products`, `/api/health`, `/api/products/search`) |
| **Integration** | Vitest | ProductsPage rendering with data, search filtering, full App composition |
| **Integration** | CI workflow | Frontend + Backend smoke test (both servers started together) |
| **E2E** | Playwright | Full user flow in a real browser — page load, navigation, search interaction |

---

## Challenges

1. **CI consistency** — Ensuring `npm ci` vs `npm install` behaves identically across local and CI environments required pinning Node.js versions and caching `package-lock.json`.
2. **Proxy configuration** — Vite's proxy needed exact path matching (`/api`) to forward to the Express backend without interfering with static assets.
3. **Test isolation** — Unit tests mock the data module so they do not depend on the backend being available; integration tests verify wiring between components.
4. **GitHub Pages deployment** — The SPA needed a correct `base` path in `vite.config.js` to serve assets from the repository sub-path.
5. **Idempotent setup** — The `run.sh` script avoids re-installing dependencies when `node_modules` is newer than `package.json`, saving time on repeated runs.

---

## Getting Started

```bash
# Clone the repository
git clone https://github.com/kanhaiyak23/devops_pratice.git
cd devops_pratice/shopsmart

# Run everything (dev mode)
bash run.sh dev

# Or run individually
cd server && npm install && npm run dev   # Backend on :5001
cd client && npm install && npm run dev   # Frontend on :5173

# Run tests
bash run.sh test
```
