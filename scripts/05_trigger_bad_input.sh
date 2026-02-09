#!/usr/bin/env bash
set -euo pipefail
STACK_NAME="${STACK_NAME:-ai6-u5w-scaleorfail}"

SM_ARN="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='StateMachineArn'].OutputValue" --output text)"
echo "State machine: $SM_ARN"

# Deterministic >5000 char payload to trigger PayloadTooLarge in Preprocess.
INPUT="$(python - <<'PY'
import json
print(json.dumps({"ticket_id":"T-BAD-1","text":"x"*5100}))
PY
)"

EXEC_ARN="$(aws stepfunctions start-execution --state-machine-arn "$SM_ARN" --input "$INPUT" --query "executionArn" --output text)"
echo "ExecutionArn: $EXEC_ARN"
echo "This execution should FAIL in Preprocess with PayloadTooLarge."
echo "Open Step Functions -> Executions -> click this execution -> see the error."
