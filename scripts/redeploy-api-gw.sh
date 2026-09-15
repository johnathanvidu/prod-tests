#!/usr/bin/env bash
#
# Triggers a Torque "Update Environment" against the bound environment so the
# API Gateway grain re-imports the freshly-uploaded swagger file.
#
# How "redeploy only the api gateway grain" is achieved:
#   The api-gw-swagger Terraform module reads the swagger object from S3 on every
#   apply and keys its deployment trigger on the object hash. After a new swagger
#   is uploaded, ONLY the api_gw_swagger grain produces a non-empty plan; the s3
#   bucket and networking grains are unchanged. Torque's smart rolling update
#   therefore re-applies only the api_gw_swagger grain.
#
# Required env vars:
#   TORQUE_TOKEN   - Torque API token (Bearer)
#   TORQUE_SPACE   - space name
#   ENV_ID         - id of the environment to update
# Optional:
#   TORQUE_API     - API base (default https://portal.qtorque.io/api)
#   GRAIN_NAME     - grain to redeploy (default api_gw_swagger)

set -euo pipefail

: "${TORQUE_TOKEN:?TORQUE_TOKEN is required}"
: "${TORQUE_SPACE:?TORQUE_SPACE is required}"
: "${ENV_ID:?ENV_ID is required}"

API="${TORQUE_API:-https://portal.qtorque.io/api}"
GRAIN_NAME="${GRAIN_NAME:-api_gw_swagger}"
AUTH=(-H "Authorization: Bearer ${TORQUE_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json")
ENV_URL="${API}/spaces/${TORQUE_SPACE}/environments/${ENV_ID}"

echo "Fetching current environment ${ENV_ID} ..."
current="$(curl -sf "${AUTH[@]}" "${ENV_URL}")"

# Re-use the environment's existing blueprint + inputs so the update only
# reconciles drift (the changed swagger object) rather than altering config.
blueprint_name="$(echo "$current" | jq -r '.details.definition.metadata.blueprint_name // .blueprint_name')"
inputs="$(echo "$current" | jq -c '.details.definition.inputs // .inputs // {}')"

echo "Updating environment to redeploy grain '${GRAIN_NAME}' (blueprint: ${blueprint_name}) ..."
payload="$(jq -n \
  --arg bp "$blueprint_name" \
  --argjson inputs "$inputs" \
  '{blueprint_name: $bp, inputs: $inputs, source: {repository_name: "bps"}}')"

http_code="$(curl -s -o /tmp/update_resp.json -w "%{http_code}" \
  -X PUT "${AUTH[@]}" -d "$payload" "${ENV_URL}")"

echo "Update response (HTTP ${http_code}):"
cat /tmp/update_resp.json; echo

case "$http_code" in
  200|201|202) echo "Environment update accepted; ${GRAIN_NAME} will redeploy from the new swagger." ;;
  *) echo "Environment update failed (HTTP ${http_code})." >&2; exit 1 ;;
esac
