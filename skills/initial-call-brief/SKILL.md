---
name: initial-call-brief
description: >-
  Use when turning a customer or prospect initial sales call into a
  structured brief — whether the call is named/looked up via the Sigma
  MCP connector's Gong Calls Enriched data model, or the transcript is
  pasted directly. Produces an "Initial Call Brief" covering business
  context, data specifics, and open questions, meant to feed directly
  into Will's Sigma Workbook Builder and/or the sigma-use-cases skill.
  Trigger on requests like "pull the brief from my call with Acme,"
  "build a workbook off this transcript," "what came out of the
  Travel Counsellors call," or whenever a transcript is pasted and the
  person wants it turned into a workbook or use-case ask.
---

# Initial Call Brief

Turns a raw sales call — named or pasted — into a structured brief
that two other skills consume: **Will's Sigma Workbook Builder** (the
workbook itself) and **sigma-use-cases** (the complementary use-case
slide). This skill only extracts and structures; it never builds a
workbook or slide itself.

## Workflow

1. **Get the transcript.**
   - If the person names a call or account ("the Acme call," "our
     call with Travel Counsellors last week"), use the Sigma MCP
     connector to query the Customer Success data model's
     `Gong Calls Enriched` element — search/filter on Account Name or
     Gong Call Title. If more than one call matches, list the
     candidates (title, date, account) and ask which one, rather than
     guessing. Pull `Full Transcript` (and `External Speaker
     Transcript` specifically, since that's the customer's own words
     — most reliable source for pain points and data mentions).
   - If a transcript is pasted directly, use it as-is — no lookup
     needed.
   - No call-type or call-number filtering — if the person named it,
     it's in scope, regardless of whether Sigma tags it `sales_call`,
     `long_sales_call`, or anything else.
2. **Extract into the brief template** (`reference/template.md`).
   Ground every field in something actually said — don't infer a data
   source or KPI that wasn't mentioned just because it seems likely.
3. **Always present the full brief to the person for review before
   doing anything else** — including every Open Decision. Wait for
   explicit confirmation or edits. Never hand off to workbook-building
   or use-case generation automatically, even when the brief looks
   complete.
4. **Once approved, hand off:**
   - The brief's "Suggested workbook goal" line → pass as the `goal`
     to `start_workbook_plan` (Will's Sigma Workbook Builder).
   - The account name + apparent industry → pass to `sigma-use-cases`
     as the target company.

## Extraction guidance

- **Use the customer's own words for pain points**, not sales
  jargon — "we're stuck exporting from three systems into Excel every
  week" tells the workbook builder more than "manual reporting
  inefficiency."
- **Data sources/systems**: capture exactly what was said, even if it
  doesn't map cleanly to a real Sigma source yet — that mapping
  happens later, inside the workbook builder's own discovery step
  (`search`/`describe`). This skill's job is to capture intent
  faithfully, not to resolve it.
- **Sentiment score** (`Full Transcript Sentiment Score` /
  `External Speaker Transcript Sentiment Score`, both -1 to 1) is
  useful context, not a hard rule — a notably negative score is worth
  flagging as an Open Decision ("call sentiment was negative — confirm
  before building anything customer-facing off this"), not silently
  acted on.
- **When the call is thin** (short, mostly logistics, little
  substance): say so plainly in the brief rather than padding out
  every section — an honest "not much data-specific content in this
  call" is more useful than invented detail.

## Handling multiple matches

When a name/account search returns several calls, show enough to
disambiguate at a glance — title, date, account, call type — and use
`ask_user_input_v0` for the pick rather than guessing off recency.

## Confidentiality

Call transcripts contain real customer names and often commercial
specifics. Don't write raw transcript text or account-identifying
details into any file that ends up committed to the repo (this
repo is private, but still — treat every generated brief as
disposable working output, not something to check in). Briefs live in
the conversation and, if saved, outside version control.

## Reference

- `reference/template.md` — the exact brief structure to fill in
