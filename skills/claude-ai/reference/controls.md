# Controls (filters)

Guidance for planning interactive filter controls on a workbook page.

## Default to shared controls

One control can drive multiple elements on a page — default to this
rather than giving every chart its own duplicate filter. Fewer widgets
on the page, and the state stays consistent across everything the
viewer is looking at.

## How many, and which kinds

- **A date range plus one key categorical filter (region, product
  line, account segment) covers most demo and exec-reporting
  scenarios.** Resist adding a control just because a column exists —
  every extra control is one more thing a viewer has to understand
  before they get to the actual insight.
- More than ~3 controls on a page starts to feel like a form rather
  than a dashboard. If the analysis genuinely needs more filtering
  depth, that's a signal for an "Ops Detail" page aimed at analysts,
  separate from the exec-facing page.

## Which control type

- **List (single or multi-select)** is the right default for
  categorical filtering — simplest to understand, demos cleanly.
- **Date range** for anything time-bound — pick the mode (relative
  "last N days" vs. fixed range) based on whether the audience wants
  a live rolling window (ops dashboards) or a fixed period they
  explicitly chose (board-deck style reporting).
- Reach for sliders, hierarchy pickers, or segmented controls only when
  the data or the ask specifically calls for it — they add visual
  interest but also add friction for a first-time viewer.

## Naming

Give controls a clear, human label ("Region," "Date Range") — not the
underlying column's raw name. The control is the thing the viewer
interacts with directly, so it deserves the plainest language on the
whole page.
