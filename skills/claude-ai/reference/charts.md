# Charts

Expanded guidance on picking and specifying chart types in a workbook
plan. This is decision-level guidance for the plan's Build Outline —
Sigma's own build step handles the underlying spec.

## Picking the right chart

Start from the question, not the chart type:

- **Trend over time** → line chart. Multiple lines for a
  category/comparison dimension (e.g. product line, year). When
  comparing periods (this year vs. last), prefer coloring by the
  actual date part (Year, Quarter) over a synthetic "Current/Prior"
  tag whenever the data spans more than one bounded window — the
  reader sees real labels they recognize instead of abstract ones.
  Reserve a synthetic Current/Prior tag for genuinely bounded windows
  ("last 30 days vs. prior 30 days") that don't map to a calendar
  period.
- **Ranking / comparison across categories** → bar chart, horizontal,
  sorted descending by the value being compared. This avoids label
  rotation and matches how people naturally scan a ranked list
  (biggest first). Reserve vertical bars for genuine time-series bar
  charts (e.g. monthly totals) where the x-axis is already ordered.
- **Actual vs. target/threshold, or two metrics on different scales**
  → combo chart (bar + line).
- **Composition of a whole** → donut/pie, capped at ~6-7 slices. Once
  it's not visually parseable, bar chart instead.
- **Outlier / relationship story** → scatter, with size encoding a
  third metric if useful (e.g. "which accounts are high-margin but
  low-volume").
- **Top/bottom N** → bar chart with an explicit top-N filter, not a
  fixed sort — this holds up as the underlying data grows or changes.

## Color and legend

- Use color to carry meaning (category, comparison period), not
  decoration. If every bar is a different color for no analytical
  reason, drop the color channel.
- Hide the legend on genuinely single-series charts — it adds nothing
  and is one more thing competing for attention.
- Keep a consistent palette across a workbook (don't let each page
  invent its own colors) — check whether Sigma's workbook theme
  already gives you a consistent categorical palette before hand-
  picking colors per chart.

## Things Sigma charts can't do (flag these early, don't discover them late)

- No true delta/percentage-change badge as a first-class KPI field —
  model comparisons as two KPIs side by side, or a calculated
  percentage-change column in a supporting table.
- No manual axis-label rotation control.
- No custom per-series colors beyond the workbook's theme palette.
- No native "small multiples" element — if the ask is a grid of mini
  charts (one per region/product), plan it as a container grid of
  individual chart elements, not a single small-multiples element.

Surfacing these as Open Decisions or plan notes up front avoids a
disappointing reveal after the workbook is already built.

## Cross-reference

See `conventions.md` for naming and layout instincts that apply to
every chart, and `kpis.md` for how a chart-adjacent KPI row should
pair with the trend chart above/below it.
