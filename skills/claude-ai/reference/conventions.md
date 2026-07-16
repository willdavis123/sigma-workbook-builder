# Conventions

Cross-cutting rules that apply regardless of which element type you're
building.

## Naming

- **Workbook title**: `<Account/Context> — <What it shows>`, e.g.
  "Aviva — Claims Volume & Attrition," "Sigma Roundup — World Cup Demo."
  Avoid version suffixes (`_v2`, `_final`) — Sigma keeps history; if you
  need a variant, say so in the title ("(Exec cut)").
- **Page names**: describe the audience or question, not the data
  source. "Executive Overview," "Regional Detail," "Cohort Analysis" —
  not "Page 1" or "Sales_Table_View."
- **Chart/table/KPI titles**: plain English, answer-shaped where
  possible. "Revenue by Region" beats "SUM(Revenue) GROUP BY Region."
  A demo or customer audience should be able to read the title and
  know what they're looking at before reading the chart itself.

## Plan discipline

- **Every open question goes in the plan as an Open Decision**, not as
  a silent assumption. Folder destination, date range, which of two
  similarly-named data sources — if it's ambiguous, surface it and
  wait for approval rather than guessing and rebuilding later.
- **Trace every metric back to something you actually inspected** via
  `describe` — not something you're assuming exists because it sounds
  plausible. If a metric isn't in the data model's metrics catalog or
  a column on the source, say so as an open decision rather than
  inventing a formula.
- **State the audience up front in the plan's Goal line.** "Exec
  overview for a 15-minute customer call" produces a very different
  build than "detailed ops dashboard for the analytics team" — same
  data, different chart density, different control count, different
  tone.

## General layout instincts

- Headline numbers (KPIs) at the top, trend in the middle, detail
  table at the bottom — the default reading order for almost any
  audience.
- Don't put more than ~3-4 distinct "sections" on one page before
  splitting into a new page. If you're scrolling to explain it, it's
  probably two pages, not one.
- Leave a little visual breathing room — not every grid cell needs to
  be filled. A slightly sparser page reads as more polished for a
  demo audience than a maximally dense one.

## When in doubt

Favor the simpler version: fewer chart types, fewer controls, a
plainer table. It's easier to add richness after seeing the first
build than to simplify something that's already overloaded. This
especially matters for demo/PoC workbooks, where the goal is a clear
story told fast, not maximum feature coverage.
