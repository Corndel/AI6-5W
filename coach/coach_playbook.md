# AI6 Unit 5.W — Coach Playbook (FINAL)

**Workshop title:** Orchestrating Complex ML Pipelines in Production  
**Session length:** 5 hours (with lunch)  
**Audience reality:** apprentices are early in Python; coaches are tired → keep it calm, visual, repeatable.

## The spine (keep repeating this)
- **Scaling is the job.**
- **Orchestration is the mechanism.**
- **Root Cause Analysis (RCA) is the safety net.**

This workshop is an MVP by design:
- learners **do not** write code
- coaches **do not** debug Python
- everything is **pre-built** and **evidence-driven**

---

## 0) Sandbox constraints (Pluralsight / A Cloud Guru)

Assume the **AWS Cloud Sandbox**:
- Regions: **us-east-1** or **us-west-2** → we standardise on **us-east-1**
- CloudShell supported (preferred)
- Services we use: **Step Functions, Lambda, CloudWatch, CloudFormation**
- We deliberately avoid “service zoo” complexity.

---

## 1) Business story (low-stakes, industry-real)

**“Flash Sale Friday” support surge**  
A subscription business sees a 10× spike in customer support tickets for ~30 minutes.

We run a triage pipeline:
1) **Preprocess** (validate + clean text) — fast
2) **Embed / “Model”** (MiniLM-style simulated) — **slow + intentionally capped**
3) **Postprocess** (simple routing + priority rules) — fast

We reference a real industry model choice:
- `sentence-transformers/all-MiniLM-L6-v2`

…but we use a deterministic simulation so the workshop is stable.

---

## 2) The key teachable moment (make it explicit)

**Question:** *What are we actually scaling?*

Answer (in this workshop):
- Preprocess and postprocess are **not** the limiting factor.
- The **model step** (Embed) is the bottleneck.
- We scale **the bottleneck capacity** (Lambda reserved concurrency).

If this point lands, the workshop succeeds.

---

## 3) What is deployed (MVP architecture)

Only:
- **Step Functions** (the orchestration map)
- **3 Lambda functions** (Preprocess → Embed → Postprocess)
- **CloudWatch dashboard + logs** (observability)
- **CloudFormation + CloudShell** (repeatable setup)

No API Gateway, no DB, no queues.

---

## 4) Before you start: how learners get the files

### Option A (recommended): upload the zip into CloudShell
1) Upload the FINAL zip in the CloudShell UI.
2) Run:

```bash
unzip ai6_unit5w_scale_or_fail_FINAL_QA.zip  # filename may differ; use the name you uploaded
cd ai6_unit5w_scale_or_fail
chmod +x scripts/*.sh
```

### Option B (backup): no-upload / paste-only
If uploads fail, use:
- `coach/cloudshell_heredoc.md`

That option lets you deploy the stack via a heredoc + `aws cloudformation deploy` copy/paste.

---

## 5) Run-of-show (timings you can trust)

### 10:00–10:20 — Opening narrative (Scaling is the job)
- Use Morning Deck slides 1–4.
- Establish the “wall”: under load, latency rises and/or throttling appears.

### 10:20–10:50 — Mental model (What are we scaling?)
- Pre vs model vs post.
- Introduce the one question: “which step is the bottleneck?”

### 10:50–11:15 — Follow‑me setup (deploy)
- Everyone deploys the stack.
- Everyone opens:
  - Step Functions state machine
  - CloudWatch dashboard

### 11:15–12:15 — Hit the wall + observe (Scaling signals)
- Run happy path once.
- Run a burst.
- Learners identify:
  - which step is throttled
  - which graph proves it

### 12:15–12:30 — Orchestration is the mechanism (only what we need)
- Show the Step Functions graph + retries.
- Key line: orchestration helps you **survive**; it doesn’t create **capacity**.

### 12:30–13:30 — Lunch

### 13:30–14:15 — RCA is the safety net (controlled)
- Controlled failure #1: bad input (Preprocess fails)
- Controlled failure #2: throttled under burst (Embed capped)

Learners use:
- `handouts/rca_tree.md` (fast classification)
- `handouts/fishbone_printable.pdf` (team reasoning)

### 14:15–14:45 — Fix + verify
- Increase reserved concurrency for Embed (2 → 10).
- Re-run burst and observe improvement.
- Capture portfolio screenshots.

### 14:45–15:00 — Transfer + close
- 10-minute Kubernetes mapping (no deep theory).
- Remind cleanup.

---

## 6) Coach “Follow‑me” commands (copy/paste)

> Run these from inside the folder:
> `ai6_unit5w_scale_or_fail/`

### A) Set region (us-east-1)
```bash
./scripts/00_set_region.sh
```

### B) Deploy the stack (CloudFormation)
```bash
./scripts/01_deploy.sh
```

Expected: stack outputs include:
- `StateMachineArn`
- `DashboardName`
- function names for preprocess/embed/postprocess

### C) Happy path (prove it works)
```bash
./scripts/02_invoke_one.sh
```

Expected output includes:
- `route` (billing/delivery/technical/cancellation)
- `route_score` (float)
- `priority` (P1/P2)
- `action` (HUMAN_REVIEW/AUTO_REPLY)

### D) Hit the wall (safe burst)
```bash
N=40 ./scripts/03_burst_load.sh
```

Expected observation (within a few minutes):
- Embed **Throttles** rises on dashboard
- Embed **Duration p95** increases (latency wall)
- (Executions may still succeed because Step Functions retries — that’s fine)

### E) Controlled failure #1: bad input
```bash
./scripts/05_trigger_bad_input.sh
```

Expected observation:
- Step Functions execution fails at **Preprocess** with `PayloadTooLarge`

### F) Fix: scale the bottleneck step
```bash
NEW_RC=10 ./scripts/04_scale_up_embed_concurrency.sh
```

Then re-run burst:
```bash
N=40 ./scripts/03_burst_load.sh
```

Expected observation:
- Throttles reduce
- Duration p95 reduces (“wall” moves)

### Cleanup (end)
```bash
./scripts/99_cleanup.sh
```

---

## 7) Learner activities (short, no chaos)

### Activity 1 (pairs, 7 minutes): “Find the model step”
Inputs:
- Step Functions execution graph
- CloudWatch dashboard

Output:
- one sentence:
  - “The bottleneck is ___ because ___ evidence.”

### Activity 2 (groups of 3, 10 minutes): “Incident report”
Template (write on paper):
- What happened? (1 sentence)
- Evidence: (one metric + one log line)
- Classification: (one of 4 leaves)
- First safe action

---

## 8) Troubleshooting (coach-only)

### Deploy fails
- Confirm region is **us-east-1** or **us-west-2**
- Re-run: `./scripts/01_deploy.sh`

### “Permission denied” when running scripts
- Run: `chmod +x scripts/*.sh`

### Not seeing throttles
- Ensure Embed reserved concurrency is still 2:
  - `aws lambda get-function-concurrency --function-name <embed-name>`
- Increase burst to 60 **only if** the sandbox is stable:
  - `N=60 ./scripts/03_burst_load.sh`

