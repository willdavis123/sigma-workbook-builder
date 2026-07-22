#!/usr/bin/env bash
# Publish workbook specs to Sigma — POST a new workbook, GET back the spec,
# fetch URL/metadata. Wraps the publish pipeline so callers don't compose
# eval/export/curl chains by hand.
#
# Usage:
#   scripts/api/publish-workbook.sh ship     <spec-file>
#   scripts/api/publish-workbook.sh post     <spec-file>
#   scripts/api/publish-workbook.sh put      <workbook-id> <spec-file>
#   scripts/api/publish-workbook.sh get-spec <workbook-id>
#   scripts/api/publish-workbook.sh get-meta <workbook-id>
#
# `ship` is the one-shot publish pipeline: validate -> POST -> GET-back
# (overwrites <spec-file> with the server's canonical spec) -> verify
# (compile-check every element) -> print the workbook URL. Use it instead of
# running post/get-spec/verify-workbook by hand. Exit code is the verify
# result (0 = all elements compiled clean), so a nonzero exit means the
# workbook published but at least one element has an unresolved formula.
#
# Auth, Accept: application/json header, and 401 auto-retry are all handled
# by the sigma_curl helper in _env.sh. Spec validation runs automatically on
# `post`/`put`/`ship` (calls scripts/validate-spec.py). No `delete` subcommand
# here — deletion stays on the direct-curl path so it always hits the DELETE
# ask pattern in .claude/settings.json.
set -euo pipefail
source "$(dirname "$0")/_env.sh"

cmd="${1:-}"
case "$cmd" in
  ship)
    spec="${2:?usage: publish-workbook.sh ship <spec-file>}"
    if [ ! -f "$spec" ]; then
      echo "publish-workbook: spec file not found: $spec" >&2
      exit 2
    fi
    here="$(dirname "$0")"
    repo_root="$(cd "$here/../.." && pwd)"

    echo "[ship 1/4] validate" >&2
    python3 "$repo_root/scripts/validate-spec.py" "$spec" >&2

    echo "[ship 2/4] POST" >&2
    resp="$(sigma_curl -X POST \
      -H "Content-Type: application/json" \
      --data-binary "@$spec" \
      "$SIGMA_BASE_URL/v2/workbooks/spec")"
    wb_id="$(printf '%s' "$resp" | python3 -c 'import sys,json
try:
    print(json.load(sys.stdin).get("workbookId",""))
except Exception:
    print("")')"
    if [ -z "$wb_id" ]; then
      echo "[ship] POST did not return a workbookId. Response:" >&2
      printf '%s\n' "$resp" >&2
      exit 1
    fi
    echo "[ship] created workbookId=$wb_id" >&2

    echo "[ship 3/4] GET-back spec -> $spec" >&2
    sigma_curl "$SIGMA_BASE_URL/v2/workbooks/$wb_id/spec" > "$spec"

    echo "[ship 4/4] verify (compile-check elements)" >&2
    verify_rc=0
    bash "$here/verify-workbook.sh" "$wb_id" >&2 || verify_rc=$?

    url="$(sigma_curl "$SIGMA_BASE_URL/v2/workbooks/$wb_id" | python3 -c 'import sys,json
try:
    print(json.load(sys.stdin).get("url",""))
except Exception:
    print("")')"

    # Machine-readable summary on stdout (stderr carried the step log).
    printf '{"workbookId":"%s","url":"%s","verify":"%s","spec":"%s"}\n' \
      "$wb_id" "$url" "$([ "$verify_rc" -eq 0 ] && echo clean || echo issues)" "$spec"
    exit "$verify_rc"
    ;;
  post)
    spec="${2:?usage: publish-workbook.sh post <spec-file>}"
    if [ ! -f "$spec" ]; then
      echo "publish-workbook: spec file not found: $spec" >&2
      exit 2
    fi
    repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
    python3 "$repo_root/scripts/validate-spec.py" "$spec"
    sigma_curl -X POST \
      -H "Content-Type: application/json" \
      --data-binary "@$spec" \
      "$SIGMA_BASE_URL/v2/workbooks/spec"
    ;;
  put)
    wb_id="${2:?usage: publish-workbook.sh put <workbook-id> <spec-file>}"
    spec="${3:?usage: publish-workbook.sh put <workbook-id> <spec-file>}"
    if [ ! -f "$spec" ]; then
      echo "publish-workbook: spec file not found: $spec" >&2
      exit 2
    fi
    repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
    python3 "$repo_root/scripts/validate-spec.py" "$spec"
    sigma_curl -X PUT \
      -H "Content-Type: application/json" \
      --data-binary "@$spec" \
      "$SIGMA_BASE_URL/v2/workbooks/$wb_id/spec"
    ;;
  get-spec)
    wb_id="${2:?usage: publish-workbook.sh get-spec <workbook-id>}"
    sigma_curl "$SIGMA_BASE_URL/v2/workbooks/$wb_id/spec"
    ;;
  get-meta)
    wb_id="${2:?usage: publish-workbook.sh get-meta <workbook-id>}"
    sigma_curl "$SIGMA_BASE_URL/v2/workbooks/$wb_id"
    ;;
  *)
    cat >&2 <<'USAGE'
usage:
  publish-workbook.sh ship     <spec-file>              (validate->POST->GET-back->verify->URL)
  publish-workbook.sh post     <spec-file>
  publish-workbook.sh put      <workbook-id> <spec-file>
  publish-workbook.sh get-spec <workbook-id>
  publish-workbook.sh get-meta <workbook-id>
USAGE
    exit 2
    ;;
esac
