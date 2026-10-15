# AI workflow

I used Claude (chat) as a pair-programming and review partner. I stayed in charge of scope, design decisions and what got committed.

## How I used it
1. **Planning first:** drafted the one-page requirements (scope, what is left out, why) before any code, then committed it as the first commit.
2. **Decisions:** compared SQLite vs PostgreSQL, hand-written pagination vs a gem, and per-currency reporting vs FX conversion, and picked the simplest option that meets the brief.
3. **TDD loop:** for each feature I committed a failing spec first (red), then the implementation (green). Commit history shows this.
4. **Hints over answers:** for the model validations and scopes I asked for hints and wrote the code myself to make sure I could explain it.
5. **Debugging:** pasted failing test output and logs, and used the explanation to fix the cause rather than patch symptoms.
6. **Deployment:** used it to plan the Render setup (Docker backend, static frontend, CORS, env vars).

## Where AI was wrong or I had to correct it
- Suggested a Rails generator type (`bigint`) that does not exist; fixed it in the migration instead.
- Suggested installing `libvips`, which broke Active Storage on my old Ubuntu. The real fix was removing the unused `image_processing` gem (the app is a JSON API).
- Start script on Render was not committed; found by reading deploy logs, not by trusting the first guess.
- Typos in my own code (`case_senstive`) were caught by the failing spec, which is why I rely on tests rather than on the AI.

## Rules I followed
- Every suggestion was run and tested before committing.
- No dependency added without a reason (pagination and median are hand-written; unused gems removed).
- Secrets never committed.
