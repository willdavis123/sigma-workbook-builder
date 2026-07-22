> **Local enrichment** — 2026-07-22. Scenario overlay for the recurring
> "personal finance / spending" demo built off the **Will Spending Model**.
> Read this alongside the baseline when a build targets that model, so a
> from-scratch re-prompt reproduces the curated look — not the naive first build.

# Will — Personal Finance demo overlay

**Trigger:** the user asks to build a spending / budget / net-worth dashboard and
the data resolves to **Will Spending Model**
(`scripts/api/mcp-search.sh "spending" --types dataModel` → id
`83e36566-264f-41dd-8d43-ca7f1e5b9f19`, urlId `40RUJNcrbtKSalaB5lDybL`, papercrane).

**Start from the exemplar.** `examples/data-model-sourced-personal-finance-multipage.json`
already encodes everything below — clone-and-modify it rather than rebuilding blind.
If building from scratch instead (e.g. for the live "watch it build" demo), apply
these curated choices explicitly:

## Curated choices to reproduce

1. **Real logo, not the placeholder.** Header logo slot is an `image` element, not
   the `**[ LOGO ]**` text placeholder:
   ```json
   { "id": "p1-logo", "kind": "image", "url": "https://ca.slack-edge.com/E07M25LCK1V-U08UD7J2KFG-99ca9f94db4f-512" }
   ```
   ⚠️ That's a **Slack CDN URL and may expire** — for a durable build, host the logo
   somewhere stable and swap the `url`.

2. **Investigation vs. supporting-table separation.** The main investigation tables
   sit up top; base/helper tables (Transactions, Spend by Month & Cat, Budget Detail)
   are pushed to the bottom under a `divider` + a bold **"Supporting Tables"** `text`
   header. Applied on the Category and Travel pages.

3. **Pivot on `Sum([Amount])`, not Spend Amount.** The Category × Subcategory × Month
   pivot uses raw `Amount` (capped to the current month) so **Income/salary and
   Transfer show** — the spend-only measure hides them by design.

4. **Monthly budget-vs-actual (not category totals).** Budget Detail's actual is a
   **month+category composite-key `Lookup`** against a *Spend by Month & Cat* table
   (grouped by month+category), so each month shows *that month's* actual and future
   months come through **blank**. The combo sums those monthly actuals per category
   vs a **current-month-capped** budget. See `specification/formulas.md` →
   "Composite-key Lookup (month + dimension)". Do NOT look up actuals by category
   alone — that repeats the whole-category total on every month, including future ones.

5. **Write-back input table is added live in Sigma** — `input-table` is rejected by
   the spec API (see `specification/tables.md`). Leave a labelled slot; the user wires
   the linked input table + future-month budget rows afterward. The warehouse budget
   table (`WD_PF_BUDGETS`) is extended with forward months via direct Snowflake SQL,
   not through Sigma.

## Also-applies (these are general conventions, already automatic)
GBP via `currencySymbol: "£"`; `Text(DatePart("year", …))` for the year overlay;
`Rollup(Max([Balance Date]), 1, 1)` for the net-worth latest-snapshot KPI; every
element carries full passthrough for drill-down.
