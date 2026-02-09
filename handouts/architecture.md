# Architecture (ASCII)

```
                (Burst load)
                     |
                     v
        +---------------------------+
        |  Step Functions (DAG)     |
        |  AI6-Unit5W-ScaleOrFail   |
        +-------------+-------------+
                      |
                      v
            +-------------------+
            | Preprocess Lambda |
            |  (fast)           |
            +---------+---------+
                      |
                      v
            +-------------------+
            | Embed / Model     |
            | Lambda (slow)     |
            | Reserved conc=2   |  <-- intentional scaling wall
            +---------+---------+
                      |
                      v
            +-------------------+
            | Postprocess       |
            | Lambda (fast)     |
            +---------+---------+
                      |
                      v
                 Output JSON

Observability:
- CloudWatch Dashboard: Duration p95, Throttles, Errors
- CloudWatch Logs: structured JSON per step
- Step Functions execution graph: where time/errors occur
```
