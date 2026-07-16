# Tables

Guidance for planning table elements.

## Plain table vs. pivot

Default to a plain table with a clear, deliberate column order. Only
reach for a pivot/cross-tab when the ask genuinely needs one — cohort
grids, region-by-month matrices, anything where the *shape itself* is
the insight. Pivots take longer to read at a glance, which matters a
lot in a live demo where you don't control the pace.

## Column order and count

- Order columns by reading priority: the dimension that identifies the
  row first, then the metrics that matter most, left to right.
- Don't include every column just because it's available — a table
  built for a demo should have exactly the columns that support the
  story, not the full source schema. Trim aggressively.

## Conditional formatting

Use it with intent, on the one or two columns where "at a glance, is
this good or bad" actually matters (e.g. below-target highlighted in
red, top performers in green). Formatting every column, or using it
decoratively, makes the table read as noisy rather than insightful —
the highlighting stops meaning anything once everything's highlighted.

## Summary bars and totals

Add a summary bar (total/average row) when the table's core purpose is
a number the reader will want without scrolling to the bottom or doing
mental math — e.g. a total row on a table of regional figures.

## Sorting

Default sort should match the story: descending by the primary metric
for a ranking table, chronological for a time-based detail table.
Don't leave a table in default source order unless that order is
itself meaningful.
