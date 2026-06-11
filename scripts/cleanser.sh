#!/usr/bin/env bash
set -eo pipefail

# Required env vars:
#   TORQUE_TOKEN  - Bearer token for Torque API auth (injected by workflow from parameter store)
#   TORQUE_SPACE  - Torque space name to operate in
#
# Optional env vars:
#   TORQUE_API_BASE  - Override base URL (default: https://portal.qtorque.io/api/v2)
#   LABEL_FILTER     - Comma-separated label selectors to filter environments by
#                      Accepts "label" (key-only) and "key:value" forms, e.g. "team:backend,env staging"
#                      TODO: replace static value below with result from external system API call

: "${TORQUE_TOKEN:?TORQUE_TOKEN is required}"
: "${TORQUE_SPACE:?TORQUE_SPACE is required}"

TORQUE_API_BASE="${TORQUE_API_BASE:-https://portal.qtorque.io/api}"
PAGE_SIZE="${PAGE_SIZE:-50}"

# TODO: replace this static list with the result of an API call to the external system
LABEL_FILTER="${LABEL_FILTER:-}"

BASE_HEADERS=(
  -H "Authorization: Bearer ${TORQUE_TOKEN}"
  -H "Accept: application/json"
  -H "Content-Type: application/json"
)

# Build label query string — each label URL-encoded directly in the URL.
# Handles both "label" (key-only) and "key:value" forms, including spaces.
LABEL_QS=""
if [[ -n "${LABEL_FILTER}" ]]; then
  IFS=',' read -ra _labels <<< "${LABEL_FILTER}"
  for _label in "${_labels[@]}"; do
    _label="${_label## }"; _label="${_label%% }"   # trim surrounding whitespace
    if [[ -n "${_label}" ]]; then
      encoded=$(jq -rn --arg v "${_label}" '$v | @uri')
      LABEL_QS+="&labels=${encoded}"
    fi
  done
fi

# ─── Fetch one page of environments ──────────────────────────────────────────

fetch_page() {
  local skip="$1"
  local url="${TORQUE_API_BASE}/spaces/${TORQUE_SPACE}/environments/v2?paging_info.skip=${skip}&paging_info.take=${PAGE_SIZE}&sort_by=StartTime&sort_by_direction=1&status=Active${LABEL_QS}"
  echo "  GET ${url}" >&2
  curl -sf "${BASE_HEADERS[@]}" "${url}"
}

# ─── End a single environment ────────────────────────────────────────────────

end_environment() {
  local env_id="$1"
  local url="${TORQUE_API_BASE}/spaces/${TORQUE_SPACE}/environments/${env_id}"

  echo "  Ending environment: ${env_id}"
  local http_status
  http_status=$(curl -s -o /dev/null -w "%{http_code}" \
    -X DELETE "${BASE_HEADERS[@]}" "${url}")

  if [[ "${http_status}" -ge 200 && "${http_status}" -lt 300 ]]; then
    echo "  ✓ Environment ${env_id} ended (HTTP ${http_status})"
  else
    echo "  ✗ Failed to end environment ${env_id} (HTTP ${http_status})" >&2
    return 1
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────────

echo "Fetching environments in space '${TORQUE_SPACE}' with label filter: '${LABEL_FILTER:-<none>}'"

skip=0
full_count=0
env_ids=()

while true; do
  response=$(fetch_page "${skip}")

  full_count=$(echo "${response}" | jq -r '.paging_info.full_count')

  page_ids=()
  while IFS= read -r env_id; do
    [[ -n "${env_id}" ]] && page_ids+=("${env_id}")
  done < <(echo "${response}" | jq -r '.environment_list[].id')

  env_ids+=("${page_ids[@]+"${page_ids[@]}"}")

  echo "  Fetched ${#env_ids[@]}/${full_count} environment(s) (skip=${skip})"

  skip=$(( skip + PAGE_SIZE ))
  [[ "${#page_ids[@]}" -eq 0 || "${skip}" -ge "${full_count}" ]] && break
done

total=${#env_ids[@]}

if [[ "${total}" -eq 0 ]]; then
  echo "No environments found matching the filter. Nothing to do."
  exit 0
fi

echo "Found ${total} environment(s) to end."

failed=0
for env_id in "${env_ids[@]}"; do
  end_environment "${env_id}" || (( failed++ )) || true
done

if [[ "${failed}" -gt 0 ]]; then
  echo "Done with errors: ${failed} environment(s) failed to end." >&2
  exit 1
fi

echo "Done. All ${total} environment(s) ended successfully."
