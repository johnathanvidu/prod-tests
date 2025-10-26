#!/bin/bash

# --- Script Configuration ---
MODULE_PATH="$TORQUE_TF_MODULE_PATH"
TERRAFORM_DIR=".terraform"

# --- Validation Checks ---

# 1. Check if the required environment variable is set
if [ -z "$MODULE_PATH" ]; then
  echo "Error: The TORQUE_TF_MODULE_PATH environment variable is not set." >&2
  exit 1
fi

TARGET_DIR="$MODULE_PATH/$TERRAFORM_DIR"

# 2. Check if the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Warning: Directory '$TARGET_DIR' does not exist. Nothing to remove."
  exit 0
fi

# --- Execution ---

echo "Attempting to remove: $TARGET_DIR"

# Use 'rm -rf' to recursively and forcefully remove the directory.
# We explicitly use 'TARGET_DIR' to avoid accidentally deleting the root filesystem.
rm -rf "$TARGET_DIR"

# --- Result ---

if [ $? -eq 0 ]; then
  echo "Successfully removed '$TERRAFORM_DIR' folder from the module path."
else
  echo "Error: Failed to remove '$TERRAFORM_DIR'. Please check permissions." >&2
  exit 1
fi
