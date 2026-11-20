# Lab 5 — Deployment & Scaling

- Due (UTC): 2026-11-15T06:59:00Z
- Points: 100
- Submission: online_url

**Assigned:** Thu Oct 29 | **Due:** Sat Nov 14, midnight  
**Chapters:** *Deployment & Scaling*, *Security, Privacy & Compliance*  
**Builds on:** Labs 1–4 — deploys your Lab 3 churn model to production

## Objective

Ship the NorthStar churn model to production using a controlled deployment strategy, and document the security and privacy posture required to deploy customer data models in an enterprise environment. After this lab, the churn model is live. The offer generation or agent system remains in staging — it will be promoted in Lab 6 after monitoring is in place.

## Starter Kit

* `scripts/teardown-lab5.sh` — deletes everything this lab can leave billing, verifies against the live API, and writes `docs/lab5-teardown-output.txt`, the evidence file the teardown gate checks.

## Getting Your Repository

Keep working in the repository you created for Lab 1, `cs401r-<your-netid>`.
This lab extends the platform you already built; **do not start a new repository.**

Lab 5 ships **one** new file. Download the Lab 5 starter kit from Canvas (or copy it from
<https://github.com/byu-cs401r4-f26/cs401r-lab5-template>) into your existing repository,
so that it sits at `scripts/teardown-lab5.sh`. Add it to what you have — do not replace
anything.

---

## Tasks & Point Breakdown

| Task | Points |
| --- | --- |
| Task 1 — Production Deployment Deploy the churn model approved above. | 30 |
| Task 2 — Operational Deployment Plan Write a deployment plan in `docs/lab5-deployment-plan.md` that a teammate who has never seen this project could execute. | 20 |
| Task 3 — Security Assessment Document the security posture of the NorthStar churn model in `docs/lab5-security-assessment.md`. | 25 |
| Task 4 — Privacy & Compliance Assessment Write a privacy impact assessment for the churn model in `docs/lab5-security-assessment.md`. | 15 |
| Task 5 — Repository Quality 1. | 10 |
| **Total** | **100** |

**Full lab guide, rubrics and worked detail:** [Open the full lab guide](https://byu.instructure.com/courses/38938/files/14361912?wrap=1)

## Submission

Submit your repository URL and the tag `lab5-submit`, including your deployment and rollback evidence.

## Submission

Submit a GitHub repository link before the deadline.
A repo that does not clone cleanly loses 20 points automatically.
Never commit AWS credentials — committed secrets = automatic 0.

**Late policy:** 10% per calendar day. Contact instructor before the deadline, not after.
