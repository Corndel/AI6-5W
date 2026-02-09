#!/usr/bin/env bash
set -euo pipefail
STACK_NAME="${STACK_NAME:-ai6-u5w-scaleorfail}"
NEW_RC="${NEW_RC:-10}"

FN_NAME="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='EmbedFunctionName'].OutputValue" --output text)"
echo "Embed function: $FN_NAME"
echo "Setting reserved concurrency to: $NEW_RC"

aws lambda put-function-concurrency --function-name "$FN_NAME" --reserved-concurrent-executions "$NEW_RC"
aws lambda get-function-concurrency --function-name "$FN_NAME" --output table
