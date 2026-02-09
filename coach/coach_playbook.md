# AI6 Unit 5.W — Coach Playbook  
## Orchestrating Complex ML Pipelines in Production  
### Scale or Fail

**Session length:** 5 hours (with lunch)  
**Audience:** Level 6 ML Engineer apprentices  
**Delivery mode:** Hands-on, guided, low-stress  
**Sandbox:** Pluralsight / A Cloud Guru — AWS Cloud Sandbox  

---

## Your "mantra for the day" (please say this early, repeat it often if you can)

> **Scaling is the job.**  
> **Orchestration is the mechanism.**  
> **Root Cause Analysis is the safety net.**

Everything in this workshop exists to support that "holy trinity" :-) In a neat way, they are learning Scaling, orchestration and RCA, which nicely ties their existing MLOps concepts together.

---

## 0) Sandbox constraints (read this first)

Assume the **AWS Cloud Sandbox** provided via Pluralsight / A Cloud Guru.

- **Regions:** us-east-1 or us-west-2  
  → we standardise on **us-east-1**
- **Access:** AWS Console + CloudShell (preferred)
- **Services used (only):**
  - AWS Step Functions
  - AWS Lambda
  - Amazon CloudWatch
  - AWS CloudFormation
- **Time limit:** ~4 hours active sandbox time  
  → **Do not start the sandbox until ~10:45**

We deliberately avoid API Gateway, databases, queues, or external services.

---

## 1) Business story (low-stakes, industry-real)

### Flash Sale Friday support surge

A subscription business experiences a **10× spike** in customer support tickets for ~30 minutes during a flash sale.

They run a simple triage pipeline:

1. **Preprocess** — validate and clean text (fast)  
2. **Embed / "Model"** — MiniLM-style embedding (slow, intentionally capped)  
3. **Postprocess** — routing + priority rules (fast)

We reference a real industry-standard model choice:

sentence-transformers/all-MiniLM-L6-v2

…but we use a **deterministic simulation** so the workshop is stable and predictable.

---

## 2) The key teachable moment (make this explicit)

### The question apprentices must answer

> **What are we actually scaling?**

### The answer in this workshop

- Preprocess is **not** the bottleneck  
- Postprocess is **not** the bottleneck  
- The **model step (Embed)** is the bottleneck  
- We scale **the bottleneck’s capacity**, not the whole pipeline

In concrete terms:
- We scale **Lambda reserved concurrency** for the Embed step

If this point lands, the workshop has succeeded.

---

## 3) What is deployed (MVP architecture)

Only the minimum needed to teach the lesson:

- **Step Functions** — the orchestration map
- **Three Lambda functions**
  - Preprocess
  - Embed (slow + capped)
  - Postprocess
- **CloudWatch**
  - Logs
  - Metrics
  - A prebuilt dashboard
- **CloudFormation** — repeatable, identical setup for everyone

No API Gateway.  
No database.  
No queues.

---

## 4) How learners get the files

### Option A (recommended): upload the zip to CloudShell

1. Upload the FINAL_QA zip in the CloudShell UI
2. Run:

```bash
unzip ai6_unit5w_scale_or_fail_FINAL_QA.zip
cd ai6_unit5w_scale_or_fail
chmod +x scripts/*.sh
```

### Option B (backup): paste-only (no upload)

If uploads fail, use:

coach/cloudshell_heredoc.md

That contains a paste-only CloudFormation deploy path.

---

## 5) Run-of-show (coach timeline)

### 10:00–10:20 — Opening narrative (Scaling is the job)

- Use Morning Deck slides 1–4.
- Establish the wall: under load, latency rises and/or throttling appears.
- Emphasise: this is a systems problem, not a Python problem.

### 10:20–10:50 — Mental model (What are we scaling?)

- Pre vs model vs post.
- Ask: "If traffic increases 10×, which step breaks first?"
- Rule: *You scale the bottleneck, not the pipeline.*

### 10:50–11:15 — Follow-me setup (deploy)

- Everyone deploys the stack.
- Everyone opens:
  - Step Functions state machine
  - CloudWatch dashboard

No exploration yet. Just orientation.

### 11:15–12:15 — Hit the wall + observe (Scaling signals)

1. Run happy path once.
2. Run a burst.
3. Learners identify:
   - which step failed
   - which graph proves it

Expected teaching signal:
- Embed shows throttling
- Some executions fail RED with TooManyRequests
- Duration p95 rises (latency wall)

Important: throttling is **not retried** in this workshop. Failures are intentional so the scaling wall is obvious.

### 12:15–12:30 — Orchestration is the mechanism (only what we need)

- Show the Step Functions graph.
- Key line: orchestration helps you organise work so scaling problems are visible; it does not create capacity.

### 12:30–13:30 — Lunch

Coach note: do not tear down the stack. Sandbox timer should still be safe if started at ~10:45.

### 13:30–14:15 — RCA is the safety net (controlled)

Two intentional incidents:

1) Bad input: Preprocess fails with PayloadTooLarge  
2) Scaling failure: Embed fails under burst due to concurrency cap

Learners use:
- handouts/rca_tree.md (fast classification)
- handouts/fishbone_printable.pdf (team reasoning)

RCA categories are scaling-specific:
- Throttled (hard limit)
- Exhausted (resource)
- Timed out (queue / dependency)
- Bad input (data)

### 14:15–14:45 — Fix + verify

- Increase reserved concurrency for Embed (2 → 10).
- Re-run burst and observe improvement.
- Capture portfolio screenshots.

### 14:45–15:00 — Transfer + close

- Optional 10-minute Kubernetes mapping (no deep theory).
- Remind cleanup.
- Re-state the spine.

---

## 6) Coach follow-me commands (copy/paste)

Run these from inside: ai6_unit5w_scale_or_fail/

### A) Set region (us-east-1)

```bash
./scripts/00_set_region.sh
```

### B) Deploy the stack

    ./scripts/01_deploy.sh

Expected outputs include:
- StateMachineArn
- DashboardName
- Lambda function names for preprocess/embed/postprocess

### C) Happy path (prove the pipeline works once)

    ./scripts/02_invoke_one.sh

Expected:
- A Step Functions execution shows **Succeeded**
- Output JSON includes:
  - route (billing/delivery/technical/cancellation)
  - route_score (float)
  - priority (P1 or P2)
  - action (HUMAN_REVIEW or AUTO_REPLY)

### D) Hit the scaling limit (burst test)

    N=40 ./scripts/03_burst_load.sh

Expected (within ~1–3 minutes, once metrics refresh):
- CloudWatch shows **Embed Throttles > 0**
- Some Step Functions executions show **Failed** at the **Embed** step with **TooManyRequests**
- CloudWatch shows **Embed Duration p95 increases** compared to the happy path

Interpretation for learners:
- The **Embed/model step** is the bottleneck under load.
- We are hitting a **capacity limit** on that step.

### E) Controlled failure #1 (bad input)

    ./scripts/05_trigger_bad_input.sh

Expected:
- The Step Functions execution shows **Failed** at the **Preprocess** step
- Error message includes **PayloadTooLarge**

Interpretation for learners:
- This is a **data/input** incident, not a scaling incident.

### F) Fix: increase capacity of the bottleneck step (scale the model step)

    NEW_RC=10 ./scripts/04_scale_up_embed_concurrency.sh

Then re-run the same burst:

    N=40 ./scripts/03_burst_load.sh

Expected (within ~1–3 minutes, once metrics refresh):
- CloudWatch shows **Embed Throttles decreases** compared to the first burst (often to 0 or near 0)
- Fewer Step Functions executions fail at **Embed** with **TooManyRequests**
- CloudWatch shows **Embed Duration p95 decreases** compared to the first burst

Interpretation for learners:
- We increased **concurrent capacity** of the bottleneck step.
- Under the same load, the system now processes more requests without throttling.

### Cleanup (end)

    ./scripts/99_cleanup.sh

---

## 7) Learner activities (suggested)

### Activity 1 (pairs, 7 minutes): Identify what is being scaled

Inputs:
- Step Functions execution graph (to locate the failing step)
- CloudWatch dashboard (to locate throttles and duration)

Output (one sentence):
- "Under burst load, the bottleneck is the **Embed/model step** because we see **Throttles > 0** and **TooManyRequests** failures at that step."

### Activity 2 (groups of 3, 10 minutes): Mini incident report (paper)

Write on paper:
- What happened? (1 sentence)
- Evidence:
  - one metric (e.g., Embed Throttles)
  - one log line or Step Functions error (e.g., TooManyRequests)
- Classification (choose one):
  - Throttled (hard limit / capacity cap)
  - Exhausted (resource e.g., memory)
  - Timed out (slow downstream or queue)
  - Bad input (data)
- First safe action (one concrete change)

---

## 8) Troubleshooting (coach-only)

### Deploy fails
- Confirm region is us-east-1 or us-west-2 (we use us-east-1)
- Re-run:

    ./scripts/01_deploy.sh

### Permission denied when running scripts
- Run:

    chmod +x scripts/*.sh

### Not seeing throttles or failures under burst
- Confirm Embed reserved concurrency is still low (e.g., 2):

    aws lambda get-function-concurrency --function-name <embed-name>

- If concurrency is not low, reset it to 2 (or redeploy the stack).
- Only if the sandbox is stable, increase burst:

    N=60 ./scripts/03_burst_load.sh

Good luck and enjoy!!
