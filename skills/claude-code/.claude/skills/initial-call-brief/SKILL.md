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

1. **Get the transcript.**
   - If the person names a call or account, look it up:
     ```bash
     # find the call
     scripts/api/mcp-search.sh "<account or call name>" --types dataModel
     # get exact column IDs for Gong Calls Enriched first, if not cached
     scripts/api/mcp-describe.sh datamodel-element <dataModelId> <elementId>
     # pull the transcript — see the script's own docstring, this is its
     # anticipated use case
     scripts/api/mcp-query.sh datamodel <dataModelId> \
       "SELECT \"<Full Transcript col id>\" FROM \"datamodel\".\"<elementId>\" WHERE \"<Account Name col id>\" = '<name>'"
     ```
     If more than one call matches, list candidates (title, date,
     account) and ask which one — don't guess.
   - If a transcript is pasted directly, use it as-is, no lookup.
   - No call-type or call-number filtering — if it's named, it's in scope.
2. **Extract into the brief template** (`reference/template.md`) —
   identical structure to the Claude.ai version. Ground every field in
   something actually said.
3. **Always show the full brief, including Open Decisions, and wait
   for explicit approval before proceeding to recon/build.** This gate
   is not optional — it mirrors the plan-approval gate already
   required later in the normal build flow (see `CLAUDE.md` → "Plan
   approval is the only authorization for state-changing API calls").
4. **Once approved, hand off into the normal flow**: the brief's
   "Suggested workbook goal" becomes the starting ask for recon (per
   `sigma-workbook-conventions`'s Recon → Plan → User approval → POST
   → GET → Visual verify sequence). Do not skip recon just because the
   brief already named a source loosely — confirm real column/table
   identifiers the normal way before authoring spec JSON.

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
