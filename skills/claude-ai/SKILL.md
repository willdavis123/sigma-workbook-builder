---
name: wills-sigma-workbook-builder
description: >-
  Use whenever building, planning, or designing a Sigma workbook or
  dashboard through the Sigma MCP connector (start_workbook_plan /
  build_workbook) — including customer demos, PoCs, internal reporting
  workbooks, or any request to "build a dashboard in Sigma," "put
  together a demo," "make a workbook off this data model/table," or
  similar. Also use when reviewing or improving a workbook plan before
  approving it. Encodes chart-type selection, KPI design, table and
  control conventions, naming standards, and common Sigma pitfalls so
  the resulting plan produces a polished, working workbook on the first
  build rather than needing several rounds of fixes.
---

# Will's Sigma Workbook Builder

This is a personal baseline, not a rigid template. Use the judgment
calls below as defaults, then bend them per scenario (customer
vertical, PoC vs. production, exec audience vs. analyst audience).

## Workflow

1. **Discover the data — and suggest, don't just assume.** Use Sigma
   MCP's `list_documents` (start with the `recommendations` collection
   when nothing's been named) and `search` to find candidate data
   models/tables. If more than one plausible source exists, list the
   top 2-3 candidates for the person with a one-line description of
   each, and ask which one to build from — don't silently pick the
   first result. Once a source is chosen (or already obvious from the
   conversation), `describe` it before planning anything. Don't guess
   at column or metric names.
2. **Start the plan.** Call `start_workbook_plan` with a one-line goal.
   It returns the plan template (Goal / Decisions / Existing State /
   Build Outline / Layout).
3. **Fill in the Build Outline and Layout using the conventions below**
   — this is where this skill adds value beyond the bare template.
   Reach for `reference/charts.md`, `kpis.md`, `tables.md`, or
   `controls.md` depending on what the workbook needs.
4. **Surface Open Decisions, don't silently assume.** If the goal is
   ambiguous (which folder, which date range, which grain), list it as
   an open decision in the plan rather than guessing — matches the
   plan-first convention: nothing gets built until the person approves
   the plan.
5. **Get approval, then call `build_workbook`** with the approved plan.
   Render the returned `workbookUrl` as a clickable link.

## Core naming & structure conventions

- **Workbook titles** — short, business-readable, no internal jargon
  (e.g. "Aviva — Claims Volume & Attrition", not "aviva_q3_v2").
- **One clear story per page.** Don't cram unrelated metrics onto one
  page just because they share a data source — split by audience or
  question ("Executive Overview" vs. "Ops Detail").
- **Every chart/table needs a plain-English title**, not the raw
  column/metric name. "Revenue by Region," not "SUM(rev) by region_cd."
- **Lead with KPIs, support with detail.** A common, reliable layout:
  KPI row at the top → 1-2 trend charts → supporting table below. This
  mirrors how most demo/exec audiences actually read a dashboard —
  headline number first, trend second, detail on demand.

## Chart type selection (decision guide)

Pick the chart type based on what question it answers, not habit:

| Question shape | Chart | Notes |
|---|---|---|
| How did X change over time? | Line chart | Use date-part color (e.g. Year) when comparing multiple periods — readers recognize real year labels rather than abstract "Current/Prior" tags. |
| How does X compare across categories? | Bar chart (horizontal) | Horizontal + sorted descending avoids label rotation and reads largest-to-smallest, the natural way people scan a ranking. |
| How does X trend AND compare to a target/threshold? | Combo chart | Bar for the actuals, line for the target/threshold. |
| What's the composition of a whole? | Donut/pie | Only when there are ≤6-7 slices — beyond that, use a bar chart instead, composition charts get unreadable fast. |
| Is there a relationship between two metrics? | Scatter (+ size for a 3rd metric) | Good for "which accounts/stores are outliers" stories. |
| What are the top/bottom N? | Bar chart + top-N filter | Don't try to fake this with sorting alone — use an explicit top-N filter so it holds up when the underlying data changes size. |

**Known chart limitations worth flagging in the plan up front** (so
they don't surprise anyone after build): no true delta/comparison
badge on KPIs — model it as two KPIs side by side instead; no axis
label rotation control; no per-series custom colors beyond the theme
palette; small multiples aren't a native element — build a grid of
individual charts instead if that's the ask.

## KPI design

- **Always pair a KPI's number with a time dimension**, even if it's
  not the headline value — this is what unlocks Sigma's automatic
  sparkline/period-comparison rendering. A naked number with no time
  context is the single most common way a KPI tile under-delivers.
- **Keep the KPI count per page tight (4-6).** More than that and the
  eye can't find the story — split across pages instead.
- Give every KPI a short, plain-English label and consider hiding the
  description entirely on polished/demo-facing workbooks (keep it for
  internal/analyst workbooks where the extra context earns its space).

## Tables

- **Default to a plain table with clear column order** — resist the
  urge to reach for a pivot table unless the ask genuinely needs a
  cross-tab (e.g. cohort or region-by-month grids). Pivots are harder
  for a demo audience to read at a glance.
- **Use conditional formatting sparingly and with intent** — highlight
  the one or two things that matter (e.g. below-target in red), not
  every column. Over-formatted tables read as noisy, not insightful.
- Add a summary bar when the table's whole point is a total/average
  that the reader will want without scrolling.

## Controls (filters)

- **One control can drive multiple elements on a page** — default to
  this rather than duplicating filters per chart. Fewer widgets, more
  consistent state.
- **Date range and a key categorical filter (region, product line,
  segment) cover most demo scenarios.** Don't over-filter a page with
  five+ controls; it starts to feel like a form, not a dashboard.
- Prefer `list` controls with single/multi-select over anything more
  exotic (sliders, hierarchy pickers) unless the data genuinely calls
  for it — simpler controls demo better and confuse fewer people.

## Making this your own

To layer in account-specific or scenario-specific patterns later
without losing the generic baseline, add new reference files with a
`local-` prefix, e.g. `reference/local-insurance-demo-patterns.md` or
`reference/local-travel-counsellors-style.md`. This keeps the core
conventions clean and reusable while letting you build up a library of
scenario overlays over time — read the relevant `local-*` file
alongside the baseline when the scenario calls for it.

## Choosing a data source

When it's not obvious which source to build from:

- Prefer a governed **data model** over a raw warehouse table when
  both exist for the same subject — data models carry pre-built
  metrics (real business logic) instead of you having to reconstruct
  aggregations from scratch.
- Check `list_documents` with `recommendations` first — these are
  curated by the workspace, so they're a strong default starting
  point over a blind keyword `search`.
- When presenting options, give each a one-line "why this one" —
  e.g. "Pipeline Movements — has Closed Won/Open Pipeline/Weighted
  Pipe metrics already built, plus a daily snapshot table with fiscal
  quarter and region for trending." A bare list of names forces the
  person to go check each one themselves, which defeats the point of
  suggesting.
- If the goal clearly names a source ("build off the Aviva claims
  table"), skip the suggestion step and go straight to `describe`.

## Reference files

- `reference/conventions.md` — naming rubric and cross-cutting rules
- `reference/charts.md` — expanded chart-type guidance and gotchas
- `reference/kpis.md` — KPI design detail
- `reference/tables.md` — table design detail
- `reference/controls.md` — control/filter design detail

(v1 deliberately covers charts, KPIs, tables, and controls only. Layout
grids, formulas, maps, and containers are intentionally left out for
now — add them as this skill matures.)
