---
name: initial-call-brief
description: >-
  Use when turning a customer/prospect initial sales call into a
  structured brief before building a Sigma workbook via the direct
  API path — whether the call is named/looked up in the Customer
  Success data model's Gong Calls Enriched element, or the transcript
  is pasted directly. Produces an "Initial Call Brief" that becomes
  the recon input for the normal sigma-workbook-conventions build
  flow (Goal / Decisions / Build Outline). Trigger whenever a
  transcript is pasted, or the user names a call/account and wants a
  workbook built off it, as the first step before recon.
---

# Initial Call Brief (Claude Code / direct API)

Same purpose as the Claude.ai version of this skill, adapted to run
entirely inside this project via the REST-API helper scripts instead
of the Sigma MCP connector — so a transcript-to-workbook session can
happen in one continuous Claude Code run.

## Workflow

1. **Get the transcript.** Two entry points — always offer both:

   **(a) Named call / account → look it up in the Gong table.** The real Gong
   calls live in the warehouse table **`GONG_CALLS_ENRICHED`** (columns
   `ACCOUNT_NAME`, `GONG_CALL_TITLE`, `GONG_CALL_DATE`, `GONG_CALL_OWNER_EMAIL`,
   `OPPORTUNITY_NAME`, `FULL_TRANSCRIPT`, plus sentiment/feature-interest fields),
   reached through the **connection** query path — not a data model. Resolve the
   table once, then query it:
     ```bash
     # 1. Find the GONG_CALLS_ENRICHED table and note its connectionId + inodeId.
     #    (Several synthetic copies may exist; describe confirms the real one via
     #     its warehouse path, e.g. DBT_SIGMA_CXA_SHARE.CORE.GONG_CALLS_ENRICHED.)
     scripts/api/mcp-search.sh "GONG_CALLS_ENRICHED" --types table
     scripts/api/mcp-describe.sh table <inodeId>     # shows Connection id + Warehouse Path + columns

     # 2. Find matching calls (list candidates if >1 — never guess which):
     scripts/api/mcp-query.sh connection <connectionId> \
       "SELECT \"ACCOUNT_NAME\", \"GONG_CALL_TITLE\", \"GONG_CALL_DATE\", \"GONG_CALL_OWNER_EMAIL\" \
        FROM \"connection\".\"<inodeId>\" \
        WHERE \"ACCOUNT_NAME\" ILIKE '%<name>%' OR \"GONG_CALL_TITLE\" ILIKE '%<name>%' \
        ORDER BY \"GONG_CALL_DATE\" DESC LIMIT 25"

     # 3. Pull the chosen call's transcript:
     scripts/api/mcp-query.sh connection <connectionId> \
       "SELECT \"FULL_TRANSCRIPT\" FROM \"connection\".\"<inodeId>\" \
        WHERE \"GONG_CALL_TITLE\" = '<exact title>'"
     ```
     Worked example (papercrane org, 2026-07): connectionId
     `9e79f38b-a310-405c-aad9-72f762ac6ff1` (**Snowflake**), inodeId
     `49c45fe7-4029-4525-b0bf-7b2a39cac3ed`. Confirm these per-org via step 1 —
     inodeIds are org-specific and there are multiple `GONG_CALLS_ENRICHED` copies.
     If more than one call matches, list candidates (title, date, account, owner)
     and ask which one — don't guess.

   **(b) Pasted transcript → use as-is, no lookup.** Always available as a
   fallback when the call isn't in the table, the connector/creds differ, or the
   user simply pastes it.

   No call-type or call-number filtering — if it's named, it's in scope.

   > **Alternate source (Will's internal access):** the same Gong data is also in
   > the `sigma-on-sigma` **Customer Success** data model (`Gong Calls Enriched`
   > element) via the native Sigma MCP connector. Prefer the connection-query path
   > above for teammate builds, since it works under the shared `.env` creds.
2. **Extract into the brief template** (`reference/template.md`) —
   identical structure to the Claude.ai version. Ground every field in
   something actually said.
3. **Always show the full brief, including Open Decisions, and wait
   for explicit approval before proceeding to recon/build.** This gate
   is not optional — it mirrors the plan-approval gate already
   required later in the normal build flow (see `CLAUDE.md` → "Plan
   approval is the only authorization for state-changing API calls").
4. **Once approved, run the build-preferences steering intake, then hand off
   into the normal flow.** Right after brief approval, run the short steering
   intake (style/palette · visual focus · layout — all defaulting to the standard
   house style) alongside the data-source gate, per `sigma-workbook-conventions`
   → "Build-preferences steering intake." The brief's "Suggested workbook goal"
   then becomes the starting ask for recon (per `sigma-workbook-conventions`'s
   Recon → Plan → User approval → POST → GET → Visual verify sequence). Do not
   skip recon just because the brief already named a source loosely — confirm
   real column/table identifiers the normal way before authoring spec JSON. The
   built workbook follows the house style (logo slot, "how to read this" aid box,
   and a "Talk Track & What's Next" page); after the first build, tell the user
   what's easy to reconfigure (per "Post-build: what you can configure").

## Why this session can now go transcript-to-workbook in one run

Because `mcp-search.sh` / `mcp-describe.sh` / `mcp-query.sh` give this
project the same discovery and query capability as the Sigma MCP
connector, the whole chain — find the call, pull the transcript,
extract the brief, get approval, recon the actual workbook source,
plan, POST, verify — happens inside one Claude Code session, under
your own credentials, no separate tool required.

## Confidentiality

Real transcripts and generated briefs may contain customer specifics.
Never write raw transcript text into `workbooks/<name>/notes.md` or
anywhere that gets committed — keep transcript content and briefs
local/ephemeral, same rule as the Claude.ai version of this skill.

## Reference

- `reference/template.md` — the exact brief structure (identical to
  the Claude.ai version — kept in sync manually, there are two copies
  by design since they run in different products)
