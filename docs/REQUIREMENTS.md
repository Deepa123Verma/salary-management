# Salary Management – Requirements

## Goal
Replace Excel sheets with a web app so the HR Manager of ACME (10,000 employees,
multiple countries) can manage salary records and answer "how do we pay people?"

## Persona
HR Manager: single user, non-technical, works with large lists daily.

## In scope (v1)
1. Employee CRUD: name, email, job title, department, country, currency, salary,
   hire date, status (active/terminated).
2. Search, filter (country, department, job title, status), sort and paginate.
   10k rows must feel instant.
3. Insights dashboard:
   - Salary min / avg / median / max by country (per currency)
   - Salary by job title within a country
   - Headcount and payroll by department
   - Salary distribution (bands)
4. Seed script: 10,000 realistic employees, fast and repeatable.
5. Input validation with clear error messages.

## Deliberately left out (and why)
- Authentication/roles: single persona; adds time, not insight.
- Currency conversion/FX: needs live rates, and mixing currencies gives wrong
  totals. We show per-currency numbers instead.
- Salary history, bonuses, equity, tax: a different problem; v2.
- Excel import: seed + CRUD cover the need for now.
- Approvals/workflow, audit logs: v2.

## Key decisions
- Salary stored as integer minor units (no float rounding errors).
- Server-side pagination and filtering; aggregates computed in SQL.
- Indexes on country, department, job_title.

## Assumptions (sent as questions to Incubyte)
- Per-currency reporting, no auth, no salary history, public demo URL.

## Success criteria
- List page responds in < 300 ms with 10k rows.
- Insights page loads in < 1 s.
- Core logic covered by fast, deterministic unit tests.
