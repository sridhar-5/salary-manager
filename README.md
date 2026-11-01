# Salary Manager

Salary Manager is ACME's compensation app. HR signs in, searches employees, and maintains salary records, payslips, salary bands, and exchange rates.

The live app is [https://melodic-semolina-9d5ec3.netlify.app/](https://melodic-semolina-9d5ec3.netlify.app/).

## Sign in

| | |
| --- | --- |
| Email | `admin@example.com` |
| Password | `password` |

This account has the **super admin** role. A super admin can use every part of the app: the employee directory, salary records, payslips, salary bands, exchange rates, reference data, and the account page.

The same account is created when you seed the local database.

## What you need

- Docker, for the local Postgres database
- Ruby 3.3.10
- Node.js 22 or newer
- Bundler

The API lives in `backend/`. The web client lives in `frontend/`.

## Backend

The API is a Rails 8 app. Local development uses Postgres from `backend/docker-compose.yml` on port **5434**, user `salary_manager`, with no password.

From `backend/`:

```bash
docker compose up -d postgres
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

The API listens on [http://localhost:3000](http://localhost:3000). A health check is available at [http://localhost:3000/up](http://localhost:3000/up).

`db:seed` loads reference data, 10,000 employees, compensation history, exchange rates, salary bands, and six months of payslips. The first seed takes a few minutes. Running it again is safe and keeps the existing admin password.

The seeded admin is `admin@example.com` / `password`, with the super admin role. Set `ADMIN_PASSWORD` before the first seed if you want a different password.

Backend tests:

```bash
bundle exec rspec
```

## Frontend

The client is a Vite + React app. It talks to the API through `VITE_API_BASE_URL`.

From `frontend/`:

```bash
npm install
```

Create `frontend/.env` and point it at the API you want:

```bash
# Local Rails API
VITE_API_BASE_URL=http://localhost:3000
```

Or use the hosted API while running the UI locally:

```bash
VITE_API_BASE_URL=https://salary-manager-466y.onrender.com
```

Start the client:

```bash
npm run dev
```

Vite serves the app at [http://localhost:5173](http://localhost:5173). Sign in with `admin@example.com` / `password`.

Other frontend commands:

```bash
npm test          # unit tests
npm run test:watch
npm run lint
npm run build
```

## Roles

| Role | What they can do |
| --- | --- |
| Super admin | Everything, including reference data (countries, departments, job titles, levels, and currencies). |
| Compensation admin | Read and update employees, salaries, payslips, salary bands, and exchange rates. |
| Viewer | Read operational and reference data. Cannot change records. |

The demo login is a super admin, so every screen is available after sign-in.
