#!/usr/bin/env bash
# Call the Sigma MCP server's `query` tool to run SQL against a connection,
# data model, or workbook. Mirrors mcp-search.sh / mcp-describe.sh — same
# JSON-RPC-over-HTTP pattern, same auth bootstrap.
#
# Needed for anything that requires an aggregation or filter the `describe`
# DDL alone can't give you — e.g. pulling a specific Gong call's Full
# Transcript by account name out of the Customer Success data model.
#
# Usage:
#   scripts/api/mcp-query.sh connection  <connectionId> <sql>
#   scripts/api/mcp-query.sh datamodel   <dataModelId>  <sql>
#   scripts/api/mcp-query.sh workbook    <workbookId>   <sql>
#
# SQL must already use the exact quoted column IDs from mcp-describe.sh —
# this script does not resolve names for you.
#
# Env:    self-bootstrapped via _env.sh (loads .env, caches OAuth token)
set -euo pipefail
source "$(dirname "$0")/_env.sh"

if [ "$#" -lt 3 ]; then
  cat >&2 <<'USAGE'
usage:
  mcp-query.sh connection <connectionId> <sql>
  mcp-query.sh datamodel  <dataModelId>  <sql>
  mcp-query.sh workbook   <workbookId>   <sql>
USAGE
  exit 2
fi

KIND="$1"; ID="$2"; SQL="$3"

python3 - "$SIGMA_BASE_URL" "$SIGMA_API_TOKEN" "$KIND" "$ID" "$SQL" <<'PY'
import json, re, sys, urllib.request

base, tok, kind, obj_id, sql = sys.argv[1:]

id_key = {"connection": "connectionId", "datamodel": "dataModelId", "workbook": "workbookId"}.get(kind)
if id_key is None:
    sys.stderr.write(f"mcp-query: unknown kind '{kind}' (expected connection|datamodel|workbook)\n")
    sys.exit(2)

body = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
        "name": "query",
        "arguments": {"query": {"type": kind, id_key: obj_id, "sql": sql}},
    },
}

req = urllib.request.Request(
    f"{base}/mcp/v2",
    data=json.dumps(body).encode(),
    headers={
        "Authorization": f"Bearer {tok}",
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
    },
)
raw = urllib.request.urlopen(req).read().decode()

m = re.search(r"data:\s*(\{.+\})", raw, re.DOTALL)
if not m:
    sys.stderr.write(f"mcp-query: unexpected response shape:\n{raw[:500]}\n")
    sys.exit(1)
envelope = json.loads(m.group(1))

if envelope.get("error"):
    sys.stderr.write(f"mcp-query: server error: {envelope['error']}\n")
    sys.exit(1)
result = envelope["result"]
if result.get("isError"):
    for c in result.get("content", []):
        if c.get("type") == "text":
            sys.stderr.write(c["text"] + "\n")
    sys.exit(1)

for c in result.get("content", []):
    if c.get("type") != "text":
        continue
    print(c["text"])
    break
PY
