# KPIs

Guidance for planning the KPI (stat card) elements in a workbook.

## The one rule that matters most

**Always give a KPI a time dimension to sit alongside its headline
number**, even when the number itself is a plain total. This is what
unlocks Sigma's automatic sparkline and period-over-period comparison
rendering. A KPI with no time context is a naked number — it looks
fine in a screenshot but doesn't hold up in a live demo when someone
asks "is that good?"

## How many, and how they read

- **4-6 KPIs per page is the sweet spot.** Beyond that, nothing reads
  as "the headline" anymore — split across pages by theme (e.g.
  Volume vs. Quality vs. Financial) rather than cramming everything
  onto one row.
- Order KPIs left-to-right by importance to the story you're telling,
  not by the order columns happen to exist in the source data.
- Keep KPI labels short and plain — "Total Revenue," "Active
  Customers" — save the caveats and definitions for a description or
  a footnote, and consider hiding the description line entirely on
  polished/demo-facing workbooks where it would just add clutter.

## What KPIs can't show (plan around these, don't promise them)

- No native delta/percentage-change badge — if the ask is explicitly
  "show the change vs. last period," plan two KPIs side by side (this
  period / last period) or a small supporting table with a %-change
  column, rather than assuming the KPI tile itself will show it.
  Sparklines cover trend, but not a specific "+12% vs last quarter"
  badge.
- No target/goal overlay on the KPI itself — if "vs. target" is the
  ask, that's a chart (actual + target line/bar), not a KPI tile.

## Pairing with the rest of the page

A KPI row works best as the opener, not the whole page — pair it with
at least one trend chart or supporting table below so the headline
number has somewhere to be explained. A page of only KPIs and nothing
else tends to raise more questions than it answers.
