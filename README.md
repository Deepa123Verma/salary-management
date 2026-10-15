# ACME Salary Management

Web app for an HR Manager to manage salary data for 10,000 employees across several countries and to answer "how do we pay people?".

- **Live app:** https://salary-management-ui-2jmm.onrender.com
- **API:** https://salary-management-ltc2.onrender.com (try `/api/v1/insights/by_country`)
- **Demo video:** <video link>

> The backend runs on a free Render instance. It sleeps after 15 minutes of inactivity, so the first request can take about a minute. Its SQLite disk is ephemeral, so the database is rebuilt and re-seeded with 10,000 employees on every start. Records added in the live demo do not survive a restart.

## Features
- Employee CRUD with validation errors shown in the form
- Search (name, email, job title), filters (country, department, status), server-side pagination
- Insights: salary min / average / median / max per country, department headcount and payroll, salary distribution bands, pay by job title
- Seed script for 10,000 realistic employees

## Tech stack
- Backend: Ruby 3.4, Rails 8 (API mode), SQLite, RSpec
- Frontend: React (Vite), MUI, Recharts

## Run locally
```bash
# backend
cd backend
bundle install
bin/rails db:setup        # creates the DB and seeds 10,000 employees
bin/rails server          # http://localhost:3000

# frontend (second terminal)
cd frontend
npm install
npm run dev               # http://localhost:5173 (proxies /api to :3000)
```

## Run tests
```bash
cd backend && bundle exec rspec
cd frontend && npm test
```

## Documentation
- [Requirements](docs/REQUIREMENTS.md): goal, scope, what is deliberately left out
- [Design notes](docs/DESIGN.md): architecture, trade-offs, performance
- [AI workflow](docs/AI_WORKFLOW.md) and [prompts](docs/PROMPTS.md)

## Assumptions
Per-currency reporting (no FX conversion), a single HR Manager user (no auth), no salary history. See the requirements document for the reasoning.
