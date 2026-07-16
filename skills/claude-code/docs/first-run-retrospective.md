# First end-to-end run — retrospective & improvement backlog

> Date: 2026-07-16. First full call-to-workbook pipeline run in Claude Code.
> Written generically (no account specifics) so it's safe to commit — see
> `Confidentiality` in the root README.

## 1. What was built (and worked well)

The whole pipeline ran end-to-end in a **single Claude Code session**, under the
user's own credentials:

1. **Initial Call Brief** — pasted transcript → structured brief → approved.
2. **Demo workbook** — 2-page Sigma workbook (29 elements) on a real data model,
   built via the direct API path.
3. **Use-case slide** — 10 tailored, defensible use cases → branded PPTX.

What worked well and should be preserved:

- **Both Sigma connections worked, side by side.** The workbook build used the
  project REST scripts (`scripts/api/*` → the user's org). The use-case slide
  used the **native Sigma MCP connector → `sigma-on-sigma`**. Two different
  Sigma instances, one session, both under the user's own auth.
- **Validation + verification held.** `validate-spec.py` (13 checks) and
  `verify-workbook.sh` (compiled-SQL check on all 29 elements) both passed, and
  KPI values were sanity-checked against the source before sign-off. Nothing
  shipped unverified.
- **Use-case generation is strong.** Grounded in *live* Use Case Agent data
  (real deployed customer apps + real prospect transcript ideas), not invented.
  The slide rendered clean on the first pass (no leftover tokens, correct tier
  mix). This is a keeper.

## 2. What needed iteration (friction to design out)

| # | What happened | Fix status |
|---|---|---|
| 1 | **Gong lookup dead-ended.** The named call wasn't in the org the REST scripts point at — only a demo `Gong Call Test` table existed there. We fell back to a pasted transcript. | See §4.B — route Gong lookup through the MCP `Customer Success` data model. |
| 2 | **`pivot-table` rejected a `style` object** with a misleading `Invalid kind: "pivot-table"` error. Removing `style` fixed it; `name` is fine. | Spawned repo task. Document in `tables.md` + add a validator check. |
| 3 | **OpenAPI URL is a 404.** `schema.md`'s "Consulting the OpenAPI" recipe can't run. Worked around by harvesting a live workbook to diff element shapes. | Spawned repo task. |
| 4 | **Two `sigma-use-cases` skills** (plugin vs project-local). The plugin one loaded first and references Claude.ai-only tools (`/mnt/user-data/outputs`, `present_files`, `ask_user_input_v0`). Had to switch to the project-local port's `scripts/api/`-and-MCP substitutions. | See §4.D. |
| 5 | **Environment mismatch discovered mid-flow.** Use Case Agent data lives in `sigma-on-sigma`, not the workbook org. Only realized the MCP connector existed partway through. | See §4.B — document the two-instance topology up front. |
| 6 | **Many permission prompts.** MCP connector tools, `pip install`, `sed`, and `python3` on non-`scripts/` files aren't allowlisted. | See §4.C — concrete allowlist additions. |
| 7 | **Several approval gates.** Brief → deliverable choice → plan → industry pick. Most are load-bearing (plan approval authorizes POST); a couple are reducible. | See §4.C. |

## 3. The load-bearing factor: DATA

A workbook is only as good as the data behind it. Two complementary angles:

### 3.A — Find real, validatable data (primary; works today)
`mcp-search.sh` / `mcp-describe.sh` (or the MCP `search`/`describe`) to locate a
data model, then **profile it with real queries before planning** (row counts,
distinct dimensions, value ranges for formatting). This is what let the demo use
correct % vs. raw-number formats and sensible aggregations. Keep doing this.

### 3.B — Tailor a typical data model when nothing fits exactly (preferred fallback)
When no data model is a clean fit, **do not** write new warehouse data. Instead,
take one of a small set of **go-to "typical" data models** and **tailor its
presentation to the use case** — the underlying data may be generic/illustrative,
but the **visuals and the language (element titles, column display names, text
blocks) match the customer's domain**. This is a reskin, not a data build:

- **Requirement:** none beyond read access — no warehouse writes, no extra creds.
- **Process:**
  1. Search for the most appropriate real data model first (§3.A). If a good one
     exists, use it directly.
  2. If not, pick from a curated shortlist of typical models/datasets whose
     *shape* matches the use case (e.g. a customer/usage feed, a transactions
     model, a projects/ops model).
  3. **Tailor language, not data:** override display names, element titles, and
     text blocks to the customer's vocabulary; choose visuals that fit the story.
     The spec's `name` fields and `text` elements do this without touching data.
  4. Build through the normal Recon → Plan → Build flow.
- **Honesty guardrail:** label tailored demos as **illustrative data** (a text
  note on the page) so no one mistakes generic figures for the customer's real
  numbers.
- **Volume:** irrelevant — the point is a convincing *look and language* match,
  not accurate figures.

**Deferred (optional, not now):** generating real mock data into a warehouse
(`CREATE TABLE`/`INSERT` into a sandbox schema) remains possible but needs write
creds and a writable schema — parked unless a scenario genuinely needs *correct*
data rather than a tailored look.

## 4. Concrete backlog for the next iteration

> **Status — 2026-07-16 update (implemented):** command allowlist (§4.C) ✅;
> Gong lookup via connection query (§4.B) ✅; find→tailor data flow (§4.A) ✅;
> logo placeholder, "how to read this" aid box, and "Talk Track & What's Next"
> page — verified on the Bicycle demo, then baked into `sigma-workbook-conventions`
> → "House style — standard template" ✅; and the **build-preferences steering
> intake** (style/palette · visual focus · layout, defaulting to house style) +
> "Post-build: what you can configure" ✅. Still open: the deeper steering /
> example-workbook matching (§4.E of the *design* discussion — partially covered by
> the intake), a `dist/` build script, and the two spawned bug tasks (pivot `style`,
> OpenAPI 404).

### A. Data — a gated "find, then tailor" branch
Add this explicit gate flow to `initial-call-brief` / `sigma-workbook-conventions`:
1. **Find** the most appropriate real data model from the call (§3.A) →
   *"This looks like it has the right data — happy to proceed with it?"*
2. **If not happy / nothing fits** → *"I can tailor one of our typical data
   models to this use case — the data would be illustrative, but the visuals and
   language will match. Happy to proceed?"* (§3.B)
3. **Then** confirm destination folder as today.
Both branches are read-only. Real mock-data generation stays deferred (§3.B).

### B. Gong lookup — route through the MCP, keep the transcript fallback
The real Gong calls appear to live in the **`sigma-on-sigma` `Customer Success`
data model** (its description explicitly includes Gong calls), reachable via the
MCP connector — not the demo table in the workbook org. Recommended change to
`initial-call-brief`:
- Do the named-call lookup against the MCP `Customer Success` data model (or a
  dedicated shared connection the user provisions for this).
- **Always keep the two entry points:** named-call lookup **OR** pasted transcript.
- This removes the dead-end we hit and lets the "name a call" path actually work.

### C. Reduce approval friction (especially for non-technical teammates)
Add to `.claude/settings.json` → `permissions.allow` (keep DELETE on `ask`):
- The Sigma MCP connector. Cleanest: ship a repo `.mcp.json` that names the
  server (e.g. `sigma`), then allowlist `mcp__sigma__*`. (Today the server ID is
  session-generated, so it can't be pre-allowlisted.)
- `Bash(python3 .claude/skills/*/assets/*.py:*)` — use-case slide rendering.
- `Bash(python3 -m pip install:*)` **or** pre-install `python-pptx` in a documented
  setup step so it never prompts.
- `Bash(sed:*)`, and a docs/OpenAPI fetch allow (`WebFetch` domain
  `help.sigmacomputing.com` or `Bash(curl * https://help.sigmacomputing.com/*)`).

Also, in the README quickstart, add one line for non-technical users: *"On the
first run Claude will ask permission for a batch of read-only helper commands —
approving them once (or 'always allow') is expected and safe; it will never
delete anything without asking."* Consider the `fewer-permission-prompts` skill
to auto-tune the allowlist from real transcripts.

### D. Disambiguate the two `sigma-use-cases` skills
Ensure the project-local port (with the Claude Code adaptation note) is the one
that loads in this repo, or rename it so it can't collide with the
`anthropic-skills` plugin copy. The plugin copy points at Claude.ai-only tools.

### E. Logos / branding on the deliverables
Default to a **manual logo placeholder** the user fills in — no auto-fetch.
**Do NOT use the Clearbit Logo API:** HubSpot sunset it (fully shut down
2025-12-01) and `logo.clearbit.com` no longer resolves.
- **Workbook:** the header carries a clearly-labeled placeholder the user
  replaces with a hosted logo URL (an `image` element once a URL is supplied; a
  `text` "[ replace with logo ]" placeholder as the safe default so nothing
  renders as a broken image).
- **Use-case slide:** the template already carries Sigma branding; a customer
  logo drops into a labeled placeholder region, populated from a **local file**
  passed to the generator (embedding a remote URL needs network at render time).
- **Optional auto-fetch (later, not default):** Logo.dev (HubSpot's recommended
  Clearbit successor — needs a free token) or Google Favicons (token-free but
  low-res). A convenience layer only.

## 5. One-line summary
The pipeline works end-to-end and both Sigma connections are solid; the
highest-leverage improvements are (1) routing Gong lookup through the MCP
Customer Success model, (2) adding a mock-data-generation fallback for the
no-data case, and (3) pre-allowlisting the MCP + a few commands so
less-technical teammates aren't buried in approval prompts.
