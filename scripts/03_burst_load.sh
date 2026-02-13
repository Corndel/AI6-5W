#!/usr/bin/env bash
set -euo pipefail

# Ensure we run from the repo root (so relative paths work).
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
STACK_NAME="${STACK_NAME:-ai6-u5w-scaleorfail}"
N="${N:-40}"
MAX_CONCURRENCY="${MAX_CONCURRENCY:-2}"

SM_ARN="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='StateMachineArn'].OutputValue | [0]" --output text)"
echo "State machine: $SM_ARN"
echo "Running batch of $N tickets with max_concurrency=$MAX_CONCURRENCY ..."

INPUT="$(python3 - <<'PY'
import json, os, itertools, pathlib

n = int(os.environ.get("N","40"))
max_c = int(os.environ.get("MAX_CONCURRENCY","2"))

# Use the provided sample tickets and repeat them to reach N items.
sample_path = pathlib.Path("data/sample_tickets.jsonl")
samples = []
for line in sample_path.read_text(encoding="utf-8").splitlines():
    if line.strip():
        samples.append(json.loads(line))

tickets = []
for i, base in zip(range(1, n+1), itertools.cycle(samples)):
    tickets.append({
        "ticket_id": f"T-{i:04d}",
        "text": base["text"]
    })

payload = {"max_concurrency": max_c, "tickets": tickets}
print(json.dumps(payload))
PY
)"

T0=$(date +%s)

EXEC_ARN="$(aws stepfunctions start-execution --state-machine-arn "$SM_ARN" --input "$INPUT" --query "executionArn" --output text)"
echo "ExecutionArn: $EXEC_ARN"
echo "Waiting for completion..."

status="RUNNING"
for i in $(seq 1 240); do
  status="$(aws stepfunctions describe-execution --execution-arn "$EXEC_ARN" --query "status" --output text)"
  [ "$status" != "RUNNING" ] && break
  sleep 2
done
if [ "$status" = "RUNNING" ]; then
  echo "Timed out waiting for execution to complete."
  exit 1
fi

T1=$(date +%s)
DUR=$((T1-T0))

echo "Status: $status"
echo "Total batch duration (seconds): $DUR"

if [ "$status" != "SUCCEEDED" ]; then
  echo ""
  echo "This execution did not succeed."
  echo "Next: Open Step Functions -> Executions -> click the execution for the failure point."
  echo "Also use CloudWatch logs for the step that failed."
  exit 1
fi

echo ""
echo "Output summary (counts):"

aws stepfunctions describe-execution --execution-arn "$EXEC_ARN" --query "output" --output json | python3 - <<'PY'
import json, sys, collections
out = json.loads(sys.stdin.read())
res = out.get("results", [])
routes = collections.Counter([r.get("route","unknown") for r in res])
priorities = collections.Counter([r.get("priority","?") for r in res])
actions = collections.Counter([r.get("action","?") for r in res])

print(f"- tickets_processed: {len(res)}")
print(f"- routes: {dict(routes)}")
print(f"- priorities: {dict(priorities)}")
print(f"- actions: {dict(actions)}")
PY

echo ""
echo "Next: CloudWatch Dashboard -> look for Embed Duration p95 and Embed ConcurrentExecutions (max)."
