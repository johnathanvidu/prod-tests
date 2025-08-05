#!/bin/bash

API_URL="https://portal.qtorque.io"

# Check if the API_TOKEN environment variable is set.
if [ -z "$TORQUE_TOKEN" ]; then
    echo "Error: The 'TORQUE_TOKEN' environment variable is not set."
    echo "Please set it before running the script:"
    echo "  export TORQUE_TOKEN=\"your_token_here\""
    exit 1
fi

# Check if exactly one argument is provided.
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 '[\"item1\", \"item2\", \"item3\"]'"
    exit 1
fi

# Check if the provided argument is a valid JSON array.
# If not, the jq command will fail and we can catch the error.
# We also check for an exit code of 0 from the parsing.
if ! jq -e '. | type == "array"' >/dev/null 2>&1 <<< "$1"; then
    echo "Error: The argument provided is not a valid JSON array."
    echo "Usage: $0 '[\"item1\", \"item2\", \"item3\"]'"
    exit 1
fi

# --- Main Logic ---
echo "Starting API calls..."
echo "API Endpoint: $API_URL"
echo "---"

jq -r '.[]' <<< "$1" | while read -r item; do
    echo "Processing item: '$item'"

    API_ENDPOINT="$API_URL/api/spaces/$item/environments"
    ESCAPED_SUBNETS=$(echo "$2" | sed 's/"/\\"/g')


    # # Construct the JSON payload for the POST request.
    # # The item is dynamically inserted into the JSON body.
    # # Using jq for this ensures correct quoting and escaping.
    read -r -d '' JSON_PAYLOAD << EOF
{
  "environment_name": "auto-subnets",
  "blueprint_name": "auto-subnets",
  "owner_email": "johnathan.v@quali.com",
  "inputs": {
    "subnets": "${ESCAPED_SUBNETS}"
  },
  "automation": true,
  "duration": "PT2H",
  "source": {
    "blueprint_name": "blueprints/auto-subnets.yaml",
    "repository_name": "bps",
  }
}
EOF
    echo $API_ENDPOINT
    echo $JSON_PAYLOAD

    # Make the API call using curl.
    # -X POST: Specifies a POST request.
    # -H "Authorization: Bearer $API_TOKEN": Sets the Authorization header with the token.
    # -H "Content-Type: application/json": Sets the content type for the JSON payload.
    # -d "$JSON_PAYLOAD": Provides the data for the request body.
    # -s: Suppress the progress meter and error messages from curl.
    # -S: Show an error message if curl fails.
    # -w "\nHTTP Status: %{http_code}\n": Print the HTTP status code on a new line.
    RESPONSE=$(curl -sS -X POST "$API_ENDPOINT" \
        -H "Authorization: Bearer $TORQUE_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD" \
        -w "\nHTTP Status: %{http_code}\n")

    # Check the exit status of the curl command.
    if [ $? -ne 0 ]; then
        echo "Curl command failed for item: '$item'"
        echo "Response: $RESPONSE"
        echo "---"
        continue # Skip to the next item
    fi

    # Print the full response.
    echo "API Response:"
    echo "$RESPONSE"
    echo "---"
done

echo "All API calls completed."