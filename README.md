# AI6 Unit 5.W — Scale or Fail (FINAL)

This is the **MVP** Unit 5.W workshop pack for AI6.

It is designed for a 5‑hour coached session where:
- apprentices **do not write code**
- coaches **do not debug Python**
- everything is **repeatable** and **evidence‑driven**
- the theme stays tight: **scalability first**

**Spine (say it all day):**
- **Scaling is the job.**
- **Orchestration is the mechanism.**
- **Root Cause Analysis (RCA) is the safety net.**

## Start here
- `coach/coach_playbook.md` — the run‑of‑show (what to say + what to click)
- `slides/morning_deck_scale_or_fail.pptx` and `slides/afternoon_deck_scale_or_fail.pptx` — ready to present
- `infra/ai6_u5w_scale_or_fail.yaml` — CloudFormation template (deployed by scripts)

## Sandbox assumptions (Pluralsight / A Cloud Guru)
We only use:
- Step Functions
- Lambda (3 functions)
- CloudWatch (dashboard + logs)
- CloudFormation + CloudShell

Region: **us-east-1** (recommended).

## Quick start (CloudShell)
1) Upload this zip into CloudShell (or download it inside CloudShell if you have a link).
2) Unzip it and enter the folder:
```bash
unzip ai6_unit5w_scale_or_fail_FINAL_QA.zip  # name may differ; use your uploaded filename
cd ai6_unit5w_scale_or_fail
chmod +x scripts/*.sh
```

3) Run the flow:
```bash
./scripts/00_set_region.sh
./scripts/01_deploy.sh
./scripts/02_invoke_one.sh
N=40 ./scripts/03_burst_load.sh
./scripts/05_trigger_bad_input.sh
NEW_RC=10 ./scripts/04_scale_up_embed_concurrency.sh
N=40 ./scripts/03_burst_load.sh
./scripts/99_cleanup.sh
```

## What you deploy
- Step Functions state machine: **Preprocess → Embed → Postprocess**
- 3 Lambda functions (Python 3.11)
- CloudWatch dashboard

The **Embed** step is intentionally configured with low reserved concurrency to create a **scaling wall**.

## Safety
Designed to be cheap and low-risk in a sandbox:
- burst size defaults to 40 (tweakable)
- no external model downloads
- no databases / queues / endpoints
