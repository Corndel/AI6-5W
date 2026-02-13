# AI6 Workshop 5 (Coach Playbook)
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

Specifically:
We demonstrate scaling using Step Functions Map parallelism. The input field max_concurrency controls how many tickets are processed in parallel. The “wall” is visible as longer batch duration when max_concurrency is low (e.g., 2). The “fix” is to rerun the same batch with a higher max_concurrency (e.g., 10).

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

1. Run our little "happy execution path" once (just processing 1 ticket)
2. Run a burst. In other words, Run a batch with the same pipeline but low Map parallelism (for example N=40, MAX_CONCURRENCY=2).
3. Learners identify:
   - what is being limited (parallel workers for the Embed/model step)
   - what evidence proves it (batch duration + orchestration view)

Expected teaching signal:
- The batch run with MAX_CONCURRENCY=2 is much slower than baseline (you’ve hit the throughput wall).
- Running the same batch with MAX_CONCURRENCY=10 is clearly faster (same work, more parallel capacity).
- In CloudWatch (optional), Embed ConcurrentExecutions (max) plateaus at the chosen parallelism, and Embed duration/overall run time reflects that constraint.

Important: in this version of the workshop, "hitting the wall” is shown as slow batch completion caused by a low Map concurrency cap (not as Lambda throttling or TooManyRequests failures).


### 12:15–12:30 — Orchestration is the mechanism (only what we need)

- Show the Step Functions graph.
- Explain that the **Map state** acts like a cloud-based for-loop.
- Emphasise that orchestration controls **how many items are processed in parallel**.
- Key line: orchestration organises work and controls parallel capacity; it does not change the model code.

---

### 12:30–13:30 — Lunch

Coach note: do not tear down the stack. Sandbox timer should still be safe if started at ~10:45.

---

### 13:30–14:15 — RCA is the safety net (controlled)

Two intentional incidents:

1) **Bad input** — Preprocess fails with `PayloadTooLarge`  
2) **Throughput limit** — Batch runs slowly because `max_concurrency` is low

Learners use:
- `handouts/rca_tree.md` (fast classification)
- `handouts/fishbone_printable.pdf` (team reasoning)

RCA categories:

- Throughput capped (parallelism limit)
- Exhausted (resource)
- Timed out (slow dependency)
- Bad input (data)

---

### 14:15–14:45 — Fix + verify

- Re-run the same batch with higher `max_concurrency` (e.g. 2 → 10).
- Compare total batch duration.
- Observe clear reduction in completion time.
- Capture screenshots for portfolio evidence.

Interpretation for learners:
- We increased **parallel processing capacity**.
- Same tickets, same code, same model.
- Faster throughput because more workers ran simultaneously.

---

### 14:45–15:00 — Transfer + close

- Optional 10-minute Kubernetes mapping:
  - Map parallelism ↔ number of worker replicas
  - Parallel workers ↔ pods / containers
- Remind cleanup.
- Re-state the spine:
  - Scaling is the job.
  - Orchestration is the mechanism.
  - RCA is the safety net.

---

## 6) Coach follow-me commands (copy/paste)

Run these from inside the repository folder.

### A) Set region

    ./scripts/00_set_region.sh

### B) Deploy the stack

    ./scripts/01_deploy.sh

Expected outputs include:
- StateMachineArn
- DashboardName
- Lambda function names for preprocess/embed/postprocess

### C) Happy path (prove the pipeline works once)

    ./scripts/02_invoke_one.sh

Expected:
- Step Functions execution shows **SUCCEEDED**
- Output JSON includes:
  - route
  - route_score
  - priority
  - action

---

### D) Hit the throughput wall (burst test)

    N=40 MAX_CONCURRENCY=2 ./scripts/03_burst_load.sh

Expected:
- Batch completion time is noticeably higher (e.g., ~15–20 seconds)
- Status: SUCCEEDED

Interpretation:
- The Embed/model step is the bottleneck.
- Throughput is capped by low parallelism.

---

### E) Scale up parallel capacity

    N=40 MAX_CONCURRENCY=10 ./scripts/03_burst_load.sh

Expected:
- Batch completion time is significantly lower (e.g., ~4–7 seconds)
- Status: SUCCEEDED

Interpretation:
- We increased parallel workers.
- Same workload, faster completion.

---

### F) Controlled failure: bad input

    ./scripts/05_trigger_bad_input.sh

Expected:
- Execution fails at Preprocess
- Error includes `PayloadTooLarge`

Interpretation:
- This is a data validation failure.
- Not a scaling issue.

---

### Cleanup

    ./scripts/99_cleanup.sh

---

## 7) Learner activities

### Activity 1 (pairs, 7 minutes): Identify what is being scaled

Inputs:
- Step Functions execution graph
- Batch duration from script output

Output (one sentence):
- “Under burst load, throughput is limited by low Map parallelism at the Embed step, as shown by slower batch completion time.”

---

### Activity 2 (groups of 3, 10 minutes): Mini incident report

Write on paper:
- What happened?
- Evidence (e.g., batch duration comparison)
- Classification (throughput cap vs bad input)
- First safe action

---

## 8) Troubleshooting (coach-only)

### Deploy fails
- Confirm region is us-east-1
- Re-run:

    ./scripts/01_deploy.sh

### Permission denied when running scripts
- Run:

    chmod +x scripts/*.sh

### Wall not visible
- Increase batch size slightly:

    N=60 MAX_CONCURRENCY=2 ./scripts/03_burst_load.sh

- Or increase simulated inference time in the stack parameter and redeploy.
