# Design notes

## Architecture
React (Vite, MUI) single-page app talks to a Rails API (JSON) backed by SQLite.

- `Employee` model: validations and filter/search scopes.
- `SalaryInsights` service: all aggregate logic, no HTTP knowledge, unit tested.
- `EmployeeSeeder` service: deterministic bulk data generation.
- Thin controllers: they parse params and render JSON.
- Frontend: one API client (`api.js`), one money formatter (`money.js`), pages for Employees and Insights.

## Key decisions and trade-offs
| Decision | Why | Trade-off / next step |
|---|---|---|
| Salary stored as integer minor units (`salary_cents`) | No float rounding errors | UI converts to and from major units in one place |
| Per-currency reporting, never summed across currencies | Adding INR and USD gives meaningless totals | A base-currency view needs FX rates (out of scope) |
| SQLite | Zero setup, fast tests, enough for 10k rows | No `PERCENTILE_CONT`, single writer; PostgreSQL at larger scale |
| Median computed in Ruby from `pluck` | SQLite has no percentile function | Fine at 10k rows; use SQL percentile on PostgreSQL |
| Hand-written offset pagination (`per_page` capped at 100) | No extra dependency | Slower on very deep pages; keyset pagination or `pagy` later |
| Service objects for insights and seeding | Logic is testable without HTTP | One more layer of indirection |
| `insert_all` in batches for seeding | 10,000 rows in seconds | Skips validations, so a spec checks every seeded row is valid |
| Debounced search and stale-response guard in the UI | Fewer API calls, no flicker from out-of-order responses | |
| Ephemeral SQLite on the free host, re-seeded on boot | Demo always has data | Edits do not persist across restarts; a managed database would fix it |

## Performance (10,000 rows, local)
- Country insights: about 90 ms
- Search + filter + paginated list: about 10 ms
- Targets from the requirements: list < 300 ms, insights < 1 s

Indexes: unique `email`, `country`, `department`, and `(country, job_title)`.

## Testing
- Model specs: validations and scopes.
- Service specs: insights (including median for odd and even counts, terminated employees excluded) and seeder (deterministic, idempotent, valid rows).
- Request specs: every endpoint, including pagination, filters, 404 and 422 responses.

## What I would do next
- Authentication and roles
- Salary history and audit log
- Excel import/export
- Frontend tests, and a `/meta/filters` endpoint instead of duplicating lists in the UI
