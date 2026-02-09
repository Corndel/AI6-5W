# AI6 Unit 5.W — Afternoon Deck (RCA Safety Net)

> Coach note: Afternoon is about *controlled investigation*. Keep it calm.
> We are not doing “debugging chaos”. We are practising a repeatable method.

---

## Slide 1 — Re-start: the spine
**Scaling is the job.**  
**Orchestration is the mechanism.**  
**Root Cause Analysis is the safety net.**

Speaker notes:
- We already saw the wall.
- Now we learn how to respond when the wall becomes a failure.

---

## Slide 2 — Orchestration: what it does for scaling
Orchestration is how we:
- split work into steps
- apply **retries/backoff**
- apply **timeouts**
- see *where time is spent*

Speaker notes:
- Orchestration doesn’t magically fix a bottleneck.
- It gives you leverage and visibility.

---

## Slide 3 — The RCA promise (low stress)
RCA is not “being clever”.
RCA is:
1) **Get evidence**
2) **Classify the bottleneck**
3) **Pick the first safe action**

Speaker notes:
- Today we do “first action”, not “perfect fix”.

---

## Slide 4 — The 4-leaf “Scaling RCA” tree
When a pipeline doesn’t scale, it is usually:

1) **Throttled** (hard limit / concurrency / quota)
2) **Exhausted** (CPU/memory per request)
3) **Timed out** (slow dependency / queue/backlog)
4) **Bad input** (payload/schema)

Speaker notes:
- We’ll practise this like triage.

---

## Slide 5 — Controlled failure #1 (Bad input)
Run:
- `./scripts/05_trigger_bad_input.sh`

Learners check:
- Step Functions execution error message:
  - `PayloadTooLarge`

Classification:
- **Bad input**

First action:
- Add validation / reject early / cap payloads (already in preprocess)

Speaker notes:
- This is boring-but-important engineering.
- “Fail fast” is a scaling strategy.

---

## Slide 6 — Controlled failure #2 (Throttled under load)
Reminder:
- Embed Lambda has reserved concurrency = 2 (intentional)

Evidence sources:
- CloudWatch dashboard: Embed Throttles
- Step Functions failures
- Execution event history shows TooManyRequests

Classification:
- **Throttled**

Speaker notes:
- This is the classic “we’re popular now” incident.

---

## Slide 7 — Activity 2 (groups of 3): Incident report in 6 minutes
Give each group this template:

**What happened?** (one sentence)  
**Evidence:** (dashboard + execution + log)  
**Classification:** (one of the 4 leaves)  
**First action:** (one safe change + why)

Coach note:
- Don’t allow “we just increase everything”.
- Make them tie evidence to action.

---

## Slide 8 — The fix (hands-on): scale the bottleneck step
Run:
- `NEW_RC=10 ./scripts/04_scale_up_embed_concurrency.sh`

Then run the burst again:
- `N=40 ./scripts/03_burst_load.sh`

Expected change:
- Throttles reduce
- More executions succeed
- “Wall” moves

Speaker notes:
- This is “horizontal scaling” in serverless terms: more concurrent workers.

---

## Slide 9 — Why this matters: scaling trade-offs (one minute)
Scaling knobs are trade-offs:
- More concurrency = more throughput
- But you can still hit:
  - account limits
  - cold starts
  - downstream bottlenecks

Speaker notes:
- Keep it short. Don’t drift into billing/SLOs.

---

## Slide 10 — The transfer: Kubernetes mapping (10 minutes max)
What you did today maps to Kubernetes:

- Lambda concurrency ↔ replica count / HPA target
- Lambda memory ↔ requests/limits
- Throttles ↔ rate limits / autoscaler lag / quota
- Step Functions graph ↔ DAG view (Argo/Airflow)
- CloudWatch metrics ↔ Prometheus/Grafana

Speaker notes:
- Don’t teach Kubernetes.
- Teach “you already know the shapes”.

---

## Slide 11 — Close: what to screenshot for portfolio
Learners capture 3 pieces of evidence:
1) A dashboard showing throttles *before* and *after*
2) A Step Functions execution showing failure (red) and success (green)
3) One sentence explaining “what we scaled” and why

Speaker notes:
- This is directly transferable to workplace narratives.

---

## Slide 12 — Cleanup reminder
Run:
- `./scripts/99_cleanup.sh`
