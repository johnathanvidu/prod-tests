#!/bin/bash

set -eo pipefail

az login --federated-token "$(cat "${AZURE_FEDERATED_TOKEN_FILE}")" \
    --service-principal \
    --username "${AZURE_CLIENT_ID}" \
    --tenant "${AZURE_TENANT_ID}" \
    --output none

# Capture the current (old) version ID before overwriting
OLD_VERSION_ID=$(az keyvault secret show \
    --vault-name "${KEYVAULT_NAME}" \
    --name "${SECRET_NAME}" \
    --query "id" \
    --output tsv | awk -F'/' '{print $NF}')

# Set new version
az keyvault secret set \
    --vault-name "${KEYVAULT_NAME}" \
    --name "${SECRET_NAME}" \
    --value "${NEW_PASSWORD}" \
    --output none

echo "New version of secret '${SECRET_NAME}' created in Key Vault '${KEYVAULT_NAME}'."

# Optionally disable the old version
if [ "${DISABLE_OLD_VERSION}" = "true" ] && [ -n "${OLD_VERSION_ID}" ]; then
    az keyvault secret set-attributes \
    --vault-name "${KEYVAULT_NAME}" \
    --name "${SECRET_NAME}" \
    --version "${OLD_VERSION_ID}" \
    --enabled false \
    --output none

    echo "Old version '${OLD_VERSION_ID}' disabled."
fi