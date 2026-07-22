# Exemplar: Personal Finance Overview (multi-page)

Harvested 2026-07-22 from a real build + user UI refinements (workbook
`34OXPZeJhX2oZgWRqWYkRC`, papercrane). Clone-and-modify base for a
multi-page, data-model-sourced dashboard.

**Design intent:** personal finance — understand spending, budget discipline,
and net worth over ~2 years, off the `Will Spending Model` data model
(transactions / budgets / account balances / subscriptions).

**Patterns worth cloning from this spec:**
- **Grand-total `Rollup` for a point-in-time scalar** — Net Worth KPI uses
  `Rollup(Max([Balance Date]), 1, 1)` to broadcast the latest snapshot date,
  then `Sum(If(Balance Date = that, Balance, 0))`. (A bare `Max()` in a plain
  column is NOT windowed — see `reference/specification/formulas.md`.)
- **Cross-element actual-vs-budget combo** — a `Lookup()` on an ungrouped
  budget table brings actuals in; the chart aggregates per category. Budget is
  capped to `Budget Month <= DateTrunc("month", Today())` so future planning
  rows don't inflate the bars.
- **Seasonal overlay line** — month-of-year on x, `Text(DatePart("year", …))`
  as the color category (wrapped in `Text()` so years render `2026`, not
  `2,026`).
- **`region-map` by country** — `regionType: "country"` with full country names.
- **Two base tables to scope one control** — pivot + detail share a dedicated
  base (`p2-txd`) so the Category control filters only them, not the combo/donut.
- **Spend vs. Amount measures** — a per-row `Spend Amount` column excludes
  Income/Transfer for spend views; the category×subcategory pivot uses raw
  `Amount` (capped to current month) so salary/income shows too.
- **GBP formatting** — `formatString: "$,.0f"` + `currencySymbol: "£"`.
- **House-style separation** — investigation elements vs. a dividered
  "Supporting Tables" section; logo image slot; Talk Track page.

**Note:** `input-table` is not authorable via the workbook-spec API — the
write-back budget input table is added live in Sigma. `folderId` is a
placeholder; set a real destination before POSTing a clone.
