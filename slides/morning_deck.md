# AI6 Unit 5.W — Morning Deck (Scalability-first)

> Coach note: This is written as a slide-by-slide *script*. Copy into your slide template.
> Learners do not need to read long text; you talk, then they click/run.

---

## Slide 1 — Title
**Orchestrating Complex ML Pipelines in Production**  
**Scale or Fail (MVP Workshop)**

Speaker notes:
- Today’s workshop is one story.
- You will not write code. You will run a real pipeline, break it under load, then fix it.

---

## Slide 2 — The Spine (North Star)
**Scaling is the job.**  
**Orchestration is the mechanism.**  
**Root Cause Analysis is the safety net.**

Speaker notes:
- Everything we do today fits one of these sentences.
- If something doesn’t fit, we ignore it.

---

## Slide 3 — Business Scenario (Low stakes, real world)
**“Flash Sale Friday” Support Surge**  
A subscription business gets **10× more support tickets** for 30 minutes.

Goal:
- Tickets are routed automatically to the right queue:
  - Billing
  - Delivery
  - Technical
  - Cancellation

Speaker notes:
- This is common in industry: triage, routing, embeddings.
- We’re not chasing accuracy today. We’re chasing *survival under load*.

---

## Slide 4 — What model are we using?
We *reference* a real industry model choice:
- `sentence-transformers/all-MiniLM-L6-v2`

In this workshop we use a **safe, deterministic simulation** that produces:
- a MiniLM-style embedding shape (384 dims)
- a route decision + confidence score

Speaker notes:
- This avoids dependency/pip-install pain and keeps coaches sane.
- The scaling behaviour is the same: the “model step” is heavier than the others.

---

## Slide 5 — The key teachable question
### What are we actually scaling?
Is the bottleneck:
- Pre-model (validation/cleanup)?
- The model step (embedding/inference)?
- Post-model (routing/formatting)?

Speaker notes:
- You only scale what is limiting you.
- If you scale the wrong thing, nothing improves.

---

## Slide 6 — The minimal system we will use
We intentionally use only:
- **AWS Step Functions** (orchestration map)
- **3 AWS Lambda functions** (pre → model → post)
- **CloudWatch dashboard + logs** (observability)
- **CloudShell + CloudFormation** (repeatable setup)

Speaker notes:
- No API Gateway. No databases. No queues. MVP only.
- Every extra service is another way to lose 30 minutes.

---

## Slide 7 — Architecture (simple)
**Step Functions** orchestrates:
1) Preprocess Lambda (fast)
2) Embed/“Model” Lambda (slow + throttled on purpose)
3) Postprocess Lambda (fast)

Speaker notes:
- The middle step is designed to be the bottleneck.
- This makes “what are we scaling?” obvious.

---

## Slide 8 — Observable reality (the only three graphs that matter)
When load increases, watch:
- **Latency** (duration p95)
- **Errors** (failed executions)
- **Throttles** (requests rejected due to limits)

Speaker notes:
- These are your production senses.

---

## Slide 9 — Your hands-on success criteria
By lunch you will be able to:
1) Run one clean “happy path” request
2) Create a burst that hits a scaling wall
3) Point to *which* step caused the wall and prove it with evidence

Evidence = dashboard + execution graph + log line.

---

## Slide 10 — Coach “follow-me” setup (1)
Open:
- AWS Console (sandbox credentials)
- Region: **us-east-1**
- CloudShell

Then run:
- `chmod +x scripts/*.sh`
- `./scripts/00_set_region.sh`
- `./scripts/01_deploy.sh`

Speaker notes:
- You can narrate while it deploys.
- Ask learners to keep the stack name exactly as provided.

---

## Slide 11 — Coach “follow-me” setup (2)
Show learners where to find:
- Step Functions → State machines → **AI6-Unit5W-ScaleOrFail-state-machine**
- CloudWatch → Dashboards → **AI6-Unit5W-ScaleOrFail-dashboard**

Speaker notes:
- Keep this visual. Don’t explain everything, just “here’s where we look later”.

---

## Slide 12 — Demo: run one ticket (happy path)
Run:
- `./scripts/02_invoke_one.sh`

What learners should see:
- execution succeeds
- output includes `route`, `route_score`, `priority`

Speaker notes:
- Confirm the pipeline works before we scale it.
- That’s a real production habit.

---

## Slide 13 — Activity 1 (pairs): Find the “model step”
Prompt:
- In the Step Functions execution graph, identify the step that represents “the model”.
- In CloudWatch dashboard, find its Duration p95 chart.

Output:
- Each pair writes one sentence:
  - “The model step is ___ because ___ evidence.”

---

## Slide 14 — Demo: hit the wall (burst)
Run:
- `N=40 ./scripts/03_burst_load.sh`

What learners should see (within a few minutes):
- Embed throttles rise
- Step Functions failures rise (some executions fail)

Speaker notes:
- The wall is intentional.
- Now we can practise the production response.

---

## Slide 15 — Mini debrief: what are we scaling?
Ask:
- Which step was throttled?
- Would scaling preprocess help?
- Would scaling postprocess help?

Answer you want:
- We scale the **embed/model step** first, because it is the bottleneck.

---

## Slide 16 — Lunch instructions
During lunch:
- Leave dashboards open.
- After lunch, we’ll investigate a “red pipeline” like a real incident.