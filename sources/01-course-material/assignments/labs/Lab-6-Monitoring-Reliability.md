# Lab 6 — Monitoring & Reliability

- Due (UTC): 2026-11-29T06:59:00Z
- Points: 100
- Submission: online_url

**Assigned:** Thu Nov 12 | **Due:** Sat Nov 28, midnight  
**Chapters:** *Metrics, Benchmarks & Guardrails*, *Monitoring & Observability*, *Reliability Engineering*  
**Builds on:** Labs 1–5 — instruments the production system deployed in Lab 5

## Objective

A deployed model with no monitoring is a liability. This lab instruments the NorthStar platform end-to-end: five monitoring layers, a full alert architecture, SLOs with error budgets, and operational runbooks for failure scenarios. After this lab, your platform can fail gracefully and recover fast.

## Starter Kit

* `scripts/preflight-lab6.sh`: checks data capture, the execution role, and processing quota before you spend anything.
* `scripts/teardown-lab6.sh`: stops in-flight processing jobs, then deletes the endpoint and everything else Lab 6 bills for.
* `monitoring/run_evidently_job.py`: the launcher.
* `monitoring/evidently_drift.py`: the analysis that runs inside the job.
* `deployment/configs/canary_deploy_realtime.py`: rolls a new endpoint config with data capture on (Prerequisite 1).

## Getting Your Repository

Keep working in the repository you created for Lab 1, `cs401r-<your-netid>`.
This lab extends the platform you already built; **do not start a new repository.**

---

## Tasks & Point Breakdown

| Task | Points |
| --- | --- |
| Task 1 — Five-Layer Monitoring Implementation Implement monitoring across all five layers for the NorthStar churn model. | 35 |
| Task 2 — Drift Detection Plan Write a drift detection plan for the NorthStar churn model in `docs/lab6-runbook.md`. | 15 |
| Task 3 — Alert Architecture Define the full alert set for the NorthStar churn model and offer generation system in `monitoring/alerts/`. | 15 |
| Task 4 — SLO Design Define SLOs for the NorthStar churn prediction model in `docs/lab6-runbook.md`. | 15 |
| Task 5 — Runbooks Write complete runbooks for **two** failure scenarios in `docs/lab6-runbook.md`. | 20 |
| **Total** | **100** |

**Full lab guide, rubrics and worked detail:** [Open the full lab guide](https://byu.instructure.com/courses/38938/files/14467805?wrap=1)

## Submission

Submit your repository URL and the tag `lab6-submit`, including `docs/lab6-runbook.md`.

## Submission

Submit a GitHub repository link before the deadline.
A repo that does not clone cleanly loses 20 points automatically.
Never commit AWS credentials — committed secrets = automatic 0.

**Late policy:** 10% per calendar day. Contact instructor before the deadline, not after.
