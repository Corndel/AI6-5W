#!/usr/bin/env bash
set -euo pipefail

NEW_MAX_CONCURRENCY="${NEW_MAX_CONCURRENCY:-10}"
N="${N:-40}"

echo "Scaling via Step Functions Map parallelism."
echo "Re-running burst with MAX_CONCURRENCY=$NEW_MAX_CONCURRENCY (N=$N)."

MAX_CONCURRENCY="$NEW_MAX_CONCURRENCY" N="$N" ./scripts/03_burst_load.sh
