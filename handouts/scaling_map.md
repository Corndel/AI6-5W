# Handout — “What are we actually scaling?” (Scaling Map)

Use this sheet every time you see latency/errors under load.

## Step 1 — Name the pipeline steps
Our pipeline has three steps:

1) **Preprocess (pre‑model)**
2) **Embed / Model (inference)**
3) **Postprocess (post‑model)**

## Step 2 — For each step, answer the same 3 questions

### A) What does this step do?
- Preprocess: validate + clean input so downstream is safe
- Embed/Model: turn text into a semantic representation (MiniLM-style) and pick the best route
- Postprocess: apply business rules (priority/action) and return a response

### B) What scaling knob exists?
- Preprocess: Lambda concurrency (horizontal) + memory/CPU per request (vertical)
- Embed/Model: Lambda concurrency + memory/CPU per request (this is usually the bottleneck)
- Postprocess: concurrency, but it often becomes a dependency bottleneck in real systems

### C) What does “failure under load” look like?
- Preprocess: input errors, schema issues, CPU spikes (rare)
- Embed/Model: throttles, long durations, timeouts, cold starts, memory pressure
- Postprocess: slow dependency symptoms (timeouts), retries, backlogs

## Step 3 — Decide: scale which part FIRST?
Pick the step that is both:
1) **slowest** (duration p95)
2) and/or **rejecting work** (throttles/errors)

Then scale that step first.
