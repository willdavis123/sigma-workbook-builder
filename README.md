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

## Quickstart (for anyone on the team — no git or terminal experience needed)

1. **Get the files.** On the repo's GitHub page, click the green **Code**
   button → **Download ZIP**. Unzip it — you now have a
   `sigma-workbook-builder` folder on your machine. No git required.
2. **Get Sigma API credentials.** Either ask Will for a shared set
   already set up for the team, or create your own in Sigma under
   **Administration → APIs and Tokens** (needs admin access — ask Will
   if you don't have it). *See [Will's separate credential setup guide
   with screenshots — link TBD] for step-by-step images.*
3. **Add your credentials.** Go into `skills/claude-code/`, find
   `.env.example`, make a copy of it in the same folder, rename the
   copy to `.env`, and open it in any text editor. Paste your
   Client ID and Client Secret into the matching lines, and check the
   comments in that file for which `SIGMA_BASE_URL` matches your org's
   region.
4. **Confirm it's working.** Open **Terminal** (Mac: Spotlight search
   → "Terminal"). Type `cd ` (with a space after it), then drag the
   `skills/claude-code` folder from Finder into the Terminal window —
   it'll paste the path in — then press Enter. Now type:
   ```
   bash scripts/api/whoami.sh
   ```
   and press Enter. **What this does, in plain English:** it's a tiny
   script that uses the credentials you just added to ask Sigma "who
   am I logged in as?" — nothing gets built or changed, it's purely a
   connection test. If it prints back your Sigma user info, you're set.
   If it errors, the likely cause is the region (`SIGMA_BASE_URL`) in
   your `.env` being wrong — double check against the comments in
   `.env.example`.
5. **Open it in Claude Code.** Open the Claude Code desktop app, and
   open the `skills/claude-code` folder (same one from step 4). Then
   just type something like: *"pull the Acme call from Gong and build
   a workbook off it."* You'll always see and approve the extracted
   call brief before anything actually gets built.
6. **That's it.** You never need to touch git, commit, or push
   anything — just review the workbook Claude Code builds via the link
   it gives you back in Sigma.

No transcript to test with yet? Just paste one directly instead of
naming a Gong call — same flow, skips the lookup step.

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

## Maintaining this repo (Will only — not needed by anyone using it)

Colleagues never touch git — only whoever's updating the repo itself
does. After making changes locally:
```bash
git add -A
git commit -m "describe what changed"
git push
```
Anyone using the repo just re-downloads the ZIP to pick up updates —
no git needed on their end either.
