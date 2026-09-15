#!/usr/bin/env bash
#
# Validates that a file is a real OpenAPI / Swagger definition before it is
# uploaded to S3 and imported into API Gateway.
#
# Checks:
#   1. File exists and is non-empty.
#   2. Parses as JSON or YAML (normalised to JSON).
#   3. Has a version marker: top-level `openapi` (3.x) or `swagger` (2.0).
#   4. Has a non-empty `paths` object.
#   5. Has `info.title`.
#
# Usage: validate-swagger.sh <path-to-file>
# Exits non-zero with a clear message if the file is not a valid swagger doc.

set -eo pipefail

src_file="${1:?usage: validate-swagger.sh <file>}"

if [ ! -s "$src_file" ]; then
  echo "VALIDATION FAILED: '$src_file' is missing or empty." >&2
  exit 1
fi

# Ensure jq is available (used for the structural assertions).
if ! command -v jq >/dev/null 2>&1; then
  sudo yum install -y jq >/dev/null 2>&1 || sudo apt-get install -y jq >/dev/null 2>&1 || true
fi
command -v jq >/dev/null 2>&1 || { echo "VALIDATION FAILED: jq is not available on the agent." >&2; exit 1; }

# Normalise the document to JSON so a single jq check covers both formats.
json=""
case "$src_file" in
  *.json)
    if ! json="$(jq -c . "$src_file" 2>/dev/null)"; then
      echo "VALIDATION FAILED: '$src_file' is not valid JSON." >&2
      exit 1
    fi
    ;;
  *.yaml|*.yml)
    if command -v yq >/dev/null 2>&1; then
      json="$(yq -o=json '.' "$src_file" 2>/dev/null)" || true
    fi
    if [ -z "$json" ] && command -v python3 >/dev/null 2>&1; then
      json="$(python3 -c 'import sys,yaml,json; json.dump(yaml.safe_load(open(sys.argv[1])), sys.stdout)' "$src_file" 2>/dev/null)" || true
    fi
    if [ -z "$json" ]; then
      echo "VALIDATION FAILED: could not parse YAML (need 'yq' or python3+pyyaml on the agent)." >&2
      exit 1
    fi
    ;;
  *)
    echo "VALIDATION FAILED: unsupported extension for '$src_file' (expected .json/.yaml/.yml)." >&2
    exit 1
    ;;
esac

# Structural OpenAPI/Swagger assertions.
errors="$(printf '%s' "$json" | jq -r '
  [
    (if (has("openapi") or has("swagger")) then empty else "missing top-level openapi/swagger version field" end),
    (if (.paths | type) == "object" then empty else "missing or invalid paths object" end),
    (if ((.paths // {}) | length) > 0 then empty else "paths object is empty (no routes defined)" end),
    (if (.info.title // "") != "" then empty else "missing info.title" end)
  ] | .[]
')"

if [ -n "$errors" ]; then
  echo "VALIDATION FAILED: not a valid OpenAPI/Swagger document:" >&2
  printf '%s\n' "$errors" | sed 's/^/  - /' >&2
  exit 1
fi

version="$(printf '%s' "$json" | jq -r '.openapi // .swagger')"
route_count="$(printf '%s' "$json" | jq -r '.paths | length')"
title="$(printf '%s' "$json" | jq -r '.info.title')"
echo "VALIDATION OK: '${title}' (spec ${version}) with ${route_count} path(s)."
