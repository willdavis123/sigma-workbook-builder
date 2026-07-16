# Call-to-Workbook

Turns an initial customer/prospect sales call — pulled from Gong via
Sigma, or pasted directly — straight into a working Sigma workbook,
with a complementary use-case slide alongside it. Built for team-wide
use across Sigma SEs, primarily inside **Claude Code**, where the
whole chain runs end-to-end under each person's own credentials.
**Private repo** — real call content and account specifics pass
through here, even though the skill code itself is generic.

## The pipeline (what this repo actually does)

```
Gong call (looked up via Sigma) or pasted transcript
        │
        ▼
initial-call-brief   — extracts a structured brief: business context,
                        data specifics, Open Decisions. ALWAYS pauses
                        for your review before anything downstream runs.
        │
        ├──▶ skills/claude-code (the primary engine) → the actual Sigma workbook
        └──▶ sigma-use-cases, offered after the build, fed the account
             name/industry already captured in the brief → PPTX + JSON
```

**Everyone on the team pulls from the same org/data model** (Customer
Success → `Gong Calls Enriched`) — no per-person source mapping
needed, just per-person credentials.

## Quickstart (for anyone on the team cloning this)

```bash
git clone https://github.com/willdavis123/sigma-workbook-builder.git
cd sigma-workbook-builder/skills/claude-code
cp .env.example .env
# fill in your own SIGMA_BASE_URL / SIGMA_CLIENT_ID / SIGMA_CLIENT_SECRET
# (Administration → APIs and Tokens in Sigma)
bash scripts/api/whoami.sh    # confirms auth is wired up correctly
```

Then open the folder in Claude Code and say something like *"pull the
Acme call from Gong and build a workbook off it."* `CLAUDE.md` routes
that straight into `initial-call-brief` first — you'll always see and
approve the extracted brief before anything gets built.

No transcript to test with yet? Paste one directly instead of naming
a Gong call — same flow, skips the lookup step.

## How it builds

`skills/claude-code/` is the only engine used for real builds — a full
Claude Code project authoring raw Sigma API specs directly (exact
chart/KPI/control specs, a 13-check pre-POST validator,
`scripts/api/` helpers for discovery, transcript lookup, and use-case
generation). This is what the quickstart above sets up, and what
`CLAUDE.md` routes every real request through.

`skills/claude-ai/` still exists in this repo, but **only as a
chat-only sandbox for quick, low-stakes testing directly in Claude.ai**
— no credentials needed, using the Sigma MCP connector's own Builder
instead of controlling the spec directly. It's how the pipeline logic
got validated early on. Don't point real customer builds at it —
`skills/claude-code/` is the one with actual control over what gets
built.

Both encode the same chart/KPI/table/control conventions; the primary
engine just goes several levels deeper (raw JSON, formulas, layout
grid, maps, containers) since it authors the workbook directly rather
than handing a plan to Sigma's Builder.

## `initial-call-brief`

Exists in both engines (`skills/initial-call-brief/` for the Claude.ai
side, `skills/claude-code/.claude/skills/initial-call-brief/` for the
primary engine) — same template, different lookup mechanism
(Sigma MCP tools vs. `scripts/api/mcp-*.sh`). No call-type or
call-number filtering: if you name the call, it's in scope, regardless
of how Sigma tags it.

## `sigma-use-cases`

Lives in `skills/claude-code/.claude/skills/sigma-use-cases/` — ported
from an existing Claude.ai skill (10 tailored use cases for a named
company, rendered to a branded PPTX + supporting JSON). Its own
`SKILL.md` has a "Claude Code adaptation note" at the top covering the
`scripts/api/` substitutions. Offered after a workbook build, fed the
account name/industry already captured by `initial-call-brief` — or
usable standalone for a cold "what could \<company\> build?" ask.

## Confidentiality

Real transcripts and generated briefs may contain customer specifics.
Never commit raw transcript text, generated briefs, or anything
account-identifying — keep those in-conversation or local, never
checked in, even though the repo itself is private.

## Test cases

See `evals/` for sanity-check prompts and what a good result looks
like for each, and `skills/claude-code/evals/` for the primary
engine's own test cases.

## Attribution

Workbook-building started from a colleague's Claude Code project
([RyanLauderback/ryan-workbook-skill](https://github.com/RyanLauderback/ryan-workbook-skill)) —
attribution kept in `skills/claude-code/README.md` and `CLAUDE.md`.
