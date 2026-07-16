# Initial Call Brief — template

Fill in every section. If a section has nothing grounded in the call,
say so explicitly ("not discussed") rather than leaving it blank or
inventing content.

```markdown
# Initial Call Brief — <Account Name>

## Call metadata
- Date:
- Duration:
- Call type (as tagged in Sigma, if looked up — otherwise "pasted transcript"):
- Attendees: (internal reps + external stakeholders, roles if stated)

## Business context
- Stated problem / pain point (their words):
- Current tools / systems mentioned:
- Why now — urgency or trigger event, if mentioned:

## Data specifics
- Data sources / systems named (verbatim, unresolved — mapping to real
  Sigma sources happens later):
- KPIs, metrics, or specific reports requested:
- Audience for the eventual workbook, if stated (exec vs. analyst,
  "for our board," etc.):

## Sentiment (if looked up via Sigma MCP)
- Full transcript sentiment score:
- External speaker sentiment score:
- Flag here if notably negative — don't act on it silently.

## Open Decisions
- Everything ambiguous, unstated, or inferred rather than said
  outright. This section should never be empty on a real call — if it
  is, look again, you probably missed something.

## Handoff
- Suggested one-line workbook goal (→ `start_workbook_plan`):
- Account name + apparent industry (→ `sigma-use-cases`):
```

## Notes on filling this in well

- The "Handoff" section is the whole point of this template — everything
  above exists to justify those two lines. If you can't write a
  confident one-line goal from what's above, the brief isn't done yet.
- Keep the "Data specifics" section in the customer's own vocabulary.
  Don't translate "that big claims spreadsheet thing" into "claims
  data warehouse table" here — that resolution is the workbook
  builder's job, using `search`/`describe` against real sources.
