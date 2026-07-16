# Evals

Lightweight test prompts for sanity-checking `sigma-workbook-builder`.
These are deliberately generic (v1 scope) — no account-specific data.
Run each prompt with the skill loaded, review the resulting plan
against the checklist, and note anything that felt off before
adjusting SKILL.md or the reference files.

## How to review a run

For each prompt, check the resulting plan against:

- [ ] Chart types match the decision guide (right chart for the
      question being asked, not just habit)
- [ ] KPIs (if any) carry a time dimension
- [ ] Controls are shared across elements, not duplicated per chart
- [ ] Titles are plain English, not raw column/metric names
- [ ] Any ambiguity was raised as an Open Decision, not silently assumed
- [ ] Page count/split matches the stated audience

## Prompts

1. `01-exec-sales-overview.md`
2. `02-ops-detail-with-filters.md`
3. `03-ambiguous-goal.md` — deliberately underspecified, to check the
   skill surfaces Open Decisions rather than guessing
