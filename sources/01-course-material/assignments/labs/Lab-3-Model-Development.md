# Lab 3 — Model Development

- Due (UTC): 2026-10-18T05:59:00Z
- Points: 100
- Submission: online_url

**Assigned:** Thu Oct 1 | **Due:** Sat Oct 17, midnight  
**Chapters:** *Model Development* (Sessions 1–3: Fine-Tuning, RAG, Agents)  
**Builds on:** Lab 2 — models train on the Feature Store features and `churn_label` you produced  
**Primary tools:** SageMaker (training, MLflow App, Model Registry), Bedrock  
**Optional (only if training on SageMaker):** Your on-demand training quota is **0** by default, so an on-demand `CreateTrainingJob` fails. Use managed spot training instead (`use_spot_instances=True` with `max_wait`), which has a non-zero default quota, or train locally. Every Track A rubric item is reachable either way.

**Prerequisite:** [Pre-Lab 3 — full guide](https://byu.instructure.com/courses/38938/files/13919668?wrap=1), due Fri Oct 2 — Tracks B and C need working Bedrock access.

## Objective

Implement two of NorthStar's three AI systems. Every student builds the churn prediction model; you then choose one LLM-based system — offer generation or the customer service agent.

This is where the platform starts doing something the business would pay for. It is also where you find out whether the features you engineered in Lab 2 were worth engineering.

---

## Starter Kit

* `churn_training_skeleton.py` — SageMaker training entry point: Feature Store Athena query, XGBoost setup with class-imbalance handling, evaluation gates, slice-evaluation stub, Model Registry registration.
* `evaluation_harness.py` — dual-track evaluation.
* `prompt_templates/offer_generation_prompts.md` — five templates carrying two documented design weaknesses plus **three planted factual errors** in the tier-guidelines block.
* `northstar-policy-docs/` — the RAG corpus for Track B: return policy, loyalty program terms, shipping policy, and an FAQ.
* `scripts/collect-lab3-evidence.sh` (with `collect_lab3_evidence.py`) — exports the evidence that exists only in your AWS account (the Athena query, your MLflow runs, your Model Registry entry) into `docs/lab3-evidence/`, checks every required evidence file, and cross-checks the numbers between them.
* `infrastructure/environments/agent/` and `agent/` — **Track C only.** The AgentCore stack in its own Terraform root (three `TODO (student)` items), the NorthStar tools and their Lambda handler, `harness_client.py` (the evaluator's `invoke_fn`, which also writes your trace and cost evidence), and `policy_tests.py`.
* `scripts/teardown-lab3.sh` — deletes endpoints and endpoint configs, stops in-flight jobs, checks for an MLflow Tracking Server, destroys the Track C agent stack if you built one, and writes `docs/lab3-teardown-output.txt`.

## Getting Your Repository

Keep working in the repository you created for Lab 1, `cs401r-<your-netid>`.
This lab extends the platform you already built; **do not start a new repository.**

Lab 3 ships **new** starter files. Download the Lab 3 starter kit from Canvas (or copy
them from <https://github.com/byu-cs401r4-f26/cs401r-lab3-template>) into your existing
repository before you begin. Add to what you have — do not replace it.

### Submitting Lab 3

**The TA grades your repository and cannot see your AWS account.** Your MLflow runs, your Model Registry entry, and the Athena query that pulled your training data are invisible to grading until you export them into the repo. Submit in this order:

1. Final training run and evaluation, with the outputs saved where *Evidence You Submit* says.
2. `bash scripts/collect-lab3-evidence.sh --track B` (or `--track C`). Fix every `FAIL`, then run it again.
3. `bash scripts/teardown-lab3.sh`.
4. Commit everything under `docs/` and `notebooks/`, then tag and push.

Tag the commit you want graded and push the tag:

```
git tag lab3-submit
git push origin lab3-submit
```

Then submit **your repository URL** in Canvas. You do not submit the tag name —
it is always `lab3-submit` for this lab, and the TA looks for it.

The TA grades `git checkout lab3-submit`, so anything you push afterwards while
starting the next lab does not change this lab's grade. **If you forget the tag, you
are graded at your last commit before the Canvas deadline** — which, if you have already
started the next lab, may not be the work you meant to submit. Tag it.

> **Public repositories, deliberately.** You may read how other students approached
> the problem. Copying their work is plagiarism and is handled under the BYU Honor
> Code — commit your own. And because these are public: never commit credentials.
> No `.env`, no `terraform.tfvars`, no AWS keys. Committed secrets are an automatic
> zero. The provided `.gitignore` already excludes them; do not remove those lines.

---

## Tasks & Point Breakdown

| Task | Points |
| --- | --- |
| Task 1 — Churn Prediction Model (Track A, required) Train a churn model on the Lab 2 Feature Store data. | 35 |
| Task 2 — LLM System: Track B or Track C Generate personalised retention offers for customers your Task 1 model flags as high-risk. | 35 |
| Task 3 — Design Justification Write `docs/lab3-model-design.md` (~700 words, not counting the track declaration at the top; the Task 1 evaluation report goes in its own file, `docs/lab3-evaluation-report.md`). | 20 |
| Task 4 — Repository Quality | 10 |
| **Total** | **100** |

**Full lab guide, rubrics and worked detail:** [Open the full lab guide](https://byu.instructure.com/courses/38938/files/14048177?wrap=1)

## Submission

Submit your repository URL and the tag `lab3-submit`, including `docs/lab3-model-design.md` and your evaluation metrics.

## Submission

Submit a GitHub repository link before the deadline.
A repo that does not clone cleanly loses 20 points automatically.
Never commit AWS credentials — committed secrets = automatic 0.

**Late policy:** 10% per calendar day. Contact instructor before the deadline, not after.
