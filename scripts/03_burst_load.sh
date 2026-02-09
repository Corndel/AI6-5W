#!/usr/bin/env bash
set -euo pipefail
STACK_NAME="${STACK_NAME:-ai6-u5w-scaleorfail}"
N="${N:-40}"
PARALLEL="${PARALLEL:-10}"

SM_ARN="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='StateMachineArn'].OutputValue" --output text)"
echo "State machine: $SM_ARN"
echo "Starting $N executions (burst) with launcher parallelism=$PARALLEL ..."

started=0
for i in $(seq 1 "$N"); do
  INPUT=$(printf '{"ticket_id":"T-%s","text":"I was charged twice for my subscription and need a refund."}' "$i")
  aws stepfunctions start-execution --state-machine-arn "$SM_ARN" --input "$INPUT" >/dev/null &
  started=$((started+1))
  # Limit local CLI fan-out so CloudShell doesn't melt.
  if (( started % PARALLEL == 0 )); then
    wait
  fi
done
wait

echo "Started $N executions."
echo "Next: CloudWatch Dashboard -> look for Embed Throttles + Duration p95."
