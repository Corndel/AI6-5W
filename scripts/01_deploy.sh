#!/usr/bin/env bash
set -euo pipefail

# Ensure we run from the repo root (so relative paths work).
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
STACK_NAME="${STACK_NAME:-ai6-u5w-scaleorfail}"
TEMPLATE_FILE="${TEMPLATE_FILE:-infra/ai6_u5w_scale_or_fail.yaml}"

echo "Deploying stack: $STACK_NAME"
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides WorkshopName="AI6-Unit5W-ScaleOrFail" SimulatedInferMs=250

echo ""
echo "Stack outputs:"
aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs" --output table
