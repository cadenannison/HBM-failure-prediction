# Lab 4 — XOps, Testing & CI/CD Pipeline

- Due (UTC): 2026-11-01T05:59:00Z
- Points: 100
- Submission: online_url

**Assigned:** Thu Oct 15 | **Due:** Sat Oct 31, midnight  
**Chapters:** *The XOps Stack* (Week 06), *Testing & Evaluation*, *XOps and Continuous Delivery* (CI/CD sections, Week 08)  
**Builds on:** Labs 1–3 — automates the lifecycle of your Lab 3 churn model

**Prerequisite:** None beyond Labs 1–3. The pipeline's training step runs on managed spot capacity, which fits within a new account's default quota, so there is no quota request to file.

## Objective

Automate everything. A model that requires manual steps to test, evaluate, and deploy is not a production system — it is a science project. This lab builds the pipeline that takes a code commit all the way to a model approved for deployment, without human intervention in the happy path.

## Starter Kit

* `buildspec.yml` — the CodeBuild build specification.
* `pipeline.yaml` — the CloudFormation stack: CodePipeline, CodeBuild, the approval topic and the build-failure alarm.
* `requirements.txt` — what CodeBuild installs in its first phase.
* `pytest.ini` — puts the repo root on the import path so plain `pytest tests/` can import `data/feature_engineering.py`.
* `tests/test_data.py`, `tests/test_features.py`, `tests/test_model.py` — populated pytest suites covering the processed dataset, the Lab 2 feature functions, and the Lab 3 model contract.
* `tests/conftest.py` — registers `--model-path` and `--eval-metrics-path`.
* `models/churn/pipeline_definition.py` — defines the SageMaker Pipeline (spot training step, then `RegisterModel` as `PendingManualApproval`).
* `models/churn/train_sagemaker.py` — the training job's entry point.
* `models/churn/churn_model.py` — **template you complete.** Your Lab 3 training logic goes here, behind a three-name contract described at the top of the file.

## Getting Your Repository

Keep working in the repository you created for Lab 1, `cs401r-<your-netid>`.
This lab extends the platform you already built; **do not start a new repository.**

Lab 4 ships **new** starter files. Download the Lab 4 starter kit from Canvas (or copy
them from <https://github.com/byu-cs401r4-f26/cs401r-lab4-template>) into your existing
repository before you begin. Add to what you have — do not replace it.

### Submitting Lab 4

When you are ready to submit, tag the commit you want graded and push the tag:

```
git tag lab4-submit
git push origin lab4-submit
```

Then submit **your repository URL** in Canvas. You do not submit the tag name —
it is always `lab4-submit` for this lab, and the TA looks for it.

The TA grades `git checkout lab4-submit`, so anything you push afterwards while
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
| Task 1 — Test Suite Build a test suite that runs automatically in CI. | 30 |
| Task 2 — CI/CD Pipeline Implement a CI/CD pipeline that connects: **code push → test → build → evaluate → register**. | 30 |
| Task 3 — MLOps Configuration Document and implement the MLOps configuration for the churn model lifecycle. | 20 |
| Task 4 — XOps Maturity Assessment Write a ~400-word maturity assessment in `docs/lab4-xops-assessment.md`. | 20 |
| **Total** | **100** |

**Full lab guide, rubrics and worked detail:** [Open the full lab guide](https://byu.instructure.com/courses/38938/files/14160931?wrap=1)

## Submission

Submit your repository URL. Tag the commit you want graded `lab4-submit` and push the tag; the TA grades that tag. The TA will introduce a deliberate test failure and verify the run halts in the phase that owns tests, reaches no registration, and fires the build-failure alarm.

## Submission

Submit a GitHub repository link before the deadline.
A repo that does not clone cleanly loses 20 points automatically.
Never commit AWS credentials — committed secrets = automatic 0.

**Late policy:** 10% per calendar day. Contact instructor before the deadline, not after.
