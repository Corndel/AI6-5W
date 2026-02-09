#!/usr/bin/env bash
set -euo pipefail
STACK_NAME="${STACK_NAME:-ai6-u5w-scaleorfail}"

SM_ARN="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='StateMachineArn'].OutputValue" --output text)"
echo "State machine: $SM_ARN"

INPUT='{"ticket_id":"T-1001","text":"My delivery is late and the tracking link is broken. Please help."}'
EXEC_ARN="$(aws stepfunctions start-execution --state-machine-arn "$SM_ARN" --input "$INPUT" --query "executionArn" --output text)"
echo "ExecutionArn: $EXEC_ARN"

echo "Waiting for completion..."
aws stepfunctions wait execution-succeeded --execution-arn "$EXEC_ARN"

echo "Output:"
aws stepfunctions describe-execution --execution-arn "$EXEC_ARN" --query "output" --output text | python -m json.tool
