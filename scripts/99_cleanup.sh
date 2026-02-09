#!/usr/bin/env bash
set -euo pipefail
STACK_NAME="${STACK_NAME:-ai6-u5w-scaleorfail}"

echo "Deleting stack: $STACK_NAME"
aws cloudformation delete-stack --stack-name "$STACK_NAME"
echo "Waiting for delete..."
aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"
echo "Deleted."
