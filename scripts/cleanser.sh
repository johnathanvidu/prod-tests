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

# TODO: replace this static list with the result of an API call to the external system
LABEL_FILTER="${LABEL_FILTER:-}"

BASE_HEADERS=(
  -H "Authorization: Bearer ${TORQUE_TOKEN}"
  -H "Accept: application/json"
  -H "Content-Type: application/json"
)

# Build label args once — one --data-urlencode "labels=..." per entry.
# curl encodes spaces and special chars; handles both "label" and "key:value" forms.
LABEL_ARGS=()
if [[ -n "${LABEL_FILTER}" ]]; then
  IFS=',' read -ra _labels <<< "${LABEL_FILTER}"
  for _label in "${_labels[@]}"; do
    _label="${_label## }"; _label="${_label%% }"   # trim surrounding whitespace
    [[ -n "${_label}" ]] && LABEL_ARGS+=(--data-urlencode "labels=${_label}")
  done
fi

# ─── Fetch one page of environments ──────────────────────────────────────────

fetch_page() {
  local page="$1"
  curl -sf -G "${BASE_HEADERS[@]}" \
    "${LABEL_ARGS[@]}" \
    --data-urlencode "paging_info.requested_page=${page}" \
    "${TORQUE_API_BASE}/v2/spaces/${TORQUE_SPACE}/environments"
}

# ─── End a single environment ────────────────────────────────────────────────

end_environment() {
  local env_id="$1"
  local url="${TORQUE_API_BASE}/spaces/${TORQUE_SPACE}/environments/${env_id}"

  echo "  Ending environment: ${env_id}"
  local http_status
  http_status=$(curl -s -o /dev/null -w "%{http_code}" \
    -X PUT "${BASE_HEADERS[@]}" "${url}")

  if [[ "${http_status}" -ge 200 && "${http_status}" -lt 300 ]]; then
    echo "  ✓ Environment ${env_id} ended (HTTP ${http_status})"
  else
    echo "  ✗ Failed to end environment ${env_id} (HTTP ${http_status})" >&2
    return 1
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────────

echo "Fetching environments in space '${TORQUE_SPACE}' with label filter: '${LABEL_FILTER:-<none>}'"

page=1
total_pages=1
env_ids=()

while [[ "${page}" -le "${total_pages}" ]]; do
  response=$(fetch_page "${page}")

  total_pages=$(echo "${response}" | jq -r '.paging_info.total_pages')

  while IFS= read -r env_id; do
    [[ -n "${env_id}" ]] && env_ids+=("${env_id}")
  done < <(echo "${response}" | jq -r '.environment_list[].id')

  echo "  Page ${page}/${total_pages} — ${#env_ids[@]} environment(s) collected so far"
  (( page++ ))
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
