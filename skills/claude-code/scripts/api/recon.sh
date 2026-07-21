#!/usr/bin/env bash
# recon.sh — one-shot data-model recon.
#
# Collapses the recon phase (describe the data model + describe each element +
# a row-count per element) into a single call, so a build's discovery step is
# one command instead of ~8. Prints, per element: the column/metric schema
# (DDL from mcp-describe) and the row count.
#
# Usage:
#   scripts/api/recon.sh <data-model-id-or-urlId>
#
# Accepts either the data-model UUID or its URL id (the trailing slug segment
# of an app.sigmacomputing.com/<org>/data-model/<name>-<urlId> link) — a
# non-UUID arg is resolved via find-file-by-urlid.sh first.
#
# This gives the schema + volume baseline every build needs. For deeper
# profiling that a specific build calls for — distinct dimension values, date
# ranges, sign/units of a measure — run a targeted follow-up with
# scripts/api/mcp-query.sh. (Adaptive profiling is intentionally NOT baked in
# here; the fixed sweep speeds the common case without boxing in the unusual
# one.)
#
# Env: self-bootstrapped via _env.sh (loads .env, caches OAuth token).
set -euo pipefail
source "$(dirname "$0")/_env.sh"
here="$(dirname "$0")"

arg="${1:?usage: recon.sh <data-model-id-or-urlId>}"

# Resolve a URL id to the data-model UUID when needed.
if printf '%s' "$arg" | grep -Eq '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'; then
  dm="$arg"
else
  echo "recon: resolving urlId '$arg' -> data-model id..." >&2
  dm="$(bash "$here/find-file-by-urlid.sh" "$arg" \
        | python3 -c 'import sys,json; print(json.load(sys.stdin).get("id",""))')"
  if [ -z "$dm" ]; then
    echo "recon: could not resolve '$arg' to a data-model id" >&2
    exit 1
  fi
fi

echo "=================================================="
echo "RECON — data model $dm"
echo "=================================================="
desc="$(bash "$here/mcp-describe.sh" datamodel "$dm")"
printf '%s\n' "$desc"

# Extract (name, elementId) pairs from the box-drawn elements table.
pairs="$(printf '%s\n' "$desc" | python3 -c '
import sys, re
# Rows look like:  ║ WD_PF_BUDGETS          │ rcXY2eQDWy │             ║
pat = re.compile(r"\s*║\s*(\S.*?)\s*│\s*([A-Za-z0-9_-]+)\s*│")
for line in sys.stdin:
    m = pat.match(line)
    if m and m.group(1) != "Name":
        print(m.group(1) + "\t" + m.group(2))
')"

if [ -z "$pairs" ]; then
  echo "recon: could not parse the element list from the describe output" >&2
  echo "recon: fall back to per-element mcp-describe.sh calls" >&2
  exit 1
fi

while IFS="$(printf '\t')" read -r name el; do
  [ -z "${el:-}" ] && continue
  echo ""
  echo "--------------------------------------------------"
  echo "### $name  ($el)"
  echo "--------------------------------------------------"
  bash "$here/mcp-describe.sh" datamodel-element "$dm" "$el"
  echo "-- row count --"
  bash "$here/mcp-query.sh" datamodel "$dm" \
    "SELECT COUNT(*) AS row_count FROM \"datamodel\".\"$el\"" 2>&1 \
    | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin); print("rows:", d["rows"][0][0])
except Exception as e:
    print("(row count unavailable:", e, ")")'
done <<< "$pairs"

echo ""
echo "recon complete — $(printf '%s\n' "$pairs" | grep -c .) element(s) profiled."
