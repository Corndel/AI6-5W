# KSB Mapping — Unit 5.W (AI6)  
## Orchestrating Complex ML Pipelines in Production (Scale or Fail)

This file maps **Unit 5.W** to the **Machine Learning Engineer (Level 6) occupational standard (ST1398 v1.0)**.

Workshop spine (used as headings and throughout delivery):
- **Scaling is the job**
- **Orchestration is the mechanism**
- **Root Cause Analysis is the safety net**

---

## Workshop-to-Duty alignment (high-level)

**Primary duties this workshop supports**
- **Duty 4:** Monitor and support ML models through operational deployment in the live environment.  
- **Duty 5:** Monitor operating resource implications; develop scalable and environmentally sustainable systems.  
- **Duty 6:** Deliver responsive technical engineering support services to mitigate operational impact whilst ensuring business continuity.
---

## Primary KSB mapping 

### Scaling is the job

**S19 — Ensure the model capacity is scaled in proportion to the operating requirements.**  
How we evidence it in 5.W: learners hit the “capacity wall” under burst load and then increase **concurrent capacity of the bottleneck step** (Embed Lambda reserved concurrency) and verify the impact.

Evidence artefacts produced in-workshop:
- Screenshot: CloudWatch widget showing **Embed Throttles** before/after.
- Screenshot: CloudWatch widget showing **Embed Duration p95** before/after.
- One sentence: “We scaled the bottleneck step (Embed) by increasing reserved concurrency from X→Y, which reduced throttles and lowered p95 duration under the same load.”


**S22 — Identify the machine learning or artificial intelligence platform architecture and specific hardware, to contribute to solving a computational problem using allocated resources.**  
How we evidence it in 5.W: learners justify *what* is being scaled (the model step vs pre/post) and *why*, using the orchestration map plus metrics.

Evidence artefacts:
- “What are we scaling?” worksheet statement:
  - “Preprocess and postprocess are not the limiting steps; Embed is the bottleneck because (metric + failure evidence).”

---

### Orchestration is the mechanism

**K12 — Deployment approaches for new data pipelines and automated processes.**  
How we evidence it in 5.W: learners use an orchestration map (Step Functions) to explain how a request travels safely through steps, and how boundaries make bottlenecks visible.

Evidence artefacts:
- Screenshot: Step Functions execution graph showing the three-step pipeline and where failures occur.
- One sentence: “Orchestration lets us isolate the bottleneck step and observe failure boundaries.”

**S10 — Apply techniques for monitoring models in the live environment to check they remain fit for purpose and stable.**  
How we evidence it in 5.W: learners use live observability signals (latency/duration, throttles, error states) to assess whether the pipeline is stable under load and after change.

Evidence artefacts:
- Screenshot: CloudWatch dashboard widgets used as the “Four Golden Signals” proxy:
  - latency/duration, traffic (invocations), errors (failures), saturation (throttles).

Note: this workshop focuses on *operational stability under load* rather than drift; drift is covered elsewhere in Unit 5.

---

### Root Cause Analysis is the safety net

**S26 — Undertake independent, impartial decision-making respecting the opinions and views of others in complex, unpredictable and changing circumstances.**  
How we evidence it in 5.W: teams classify incidents using an RCA tree and fishbone, select the most likely root cause, and propose one safe action, with evidence.

Evidence artefacts:
- Completed RCA Tree (4-leaf classification).
- Completed Fishbone (scaling-centric categories).
- “Mini incident report” (what happened, evidence, classification, first action).

**B2 — Takes personal responsibility and prioritises sustainable outcomes in how they carry out the duties of their role.**  
How we evidence it in 5.W: learners treat scaling and observability as *responsibility for service continuity*, not just “cool modelling”.

Evidence artefacts:
- One sentence reflection: “What would you check first at 03:00 and why?”

**B4 — Acts with integrity, giving due regard to legal, ethical and regulatory requirements.**  
How we evidence it in 5.W: learners use disciplined evidence-based RCA (no guessing; state what you know vs assume). This is “integrity” in technical decision-making.

Evidence artefacts:
- Incident report explicitly separates “Evidence” from “Hypothesis”.

---

## Secondary (optional) mappings

- **K11 — How machine learning methods are applied to maximise the impact to the organisation.**  
  Optional (going further): Framing “why scaling matters” in business terms (lost revenue, degraded customer experience, operational load).

---

## References

- **Machine learning engineer (Level 6) occupational standard, ST1398 v1.0 (Skills England)**
