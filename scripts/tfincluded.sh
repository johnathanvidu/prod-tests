#!/bin/bash

# Path to the terraform executable
TERRAFORM_PATH="/app/1.5.5/terraform"

# Check if the terraform executable exists
if [ -f "$TERRAFORM_PATH" ]; then
    echo "Terraform executable found."
else
    echo "Terraform executable not found."
    exit 1
fi
