# Lab 2 — Data & Feature Engineering

- Due (UTC): 2026-10-04T05:59:00Z
- Points: 100
- Submission: online_url

**Assigned:** Thu Sep 17 | **Due:** Sat Oct 3, midnight  
**Chapter:** *Data & Feature Engineering*  
**Builds on:** Lab 1 — your S3 bucket, VPC, MLEngineer role, and Terraform codebase  
**Primary tool:** Terraform (all infrastructure changes are IaC from this point forward)

## Objective

Extend the NorthStar platform in two directions. First, harden the infrastructure left intentionally simple in Lab 1: move SageMaker into a private subnet behind a NAT Gateway, add the DataEngineer and ModelMonitor IAM roles, and add S3 lifecycle rules. Second, build the data pipeline that feeds the ML platform: raw data lands in S3, Glue crawls and transforms it, and engineered features are written to SageMaker Feature Store.

By the end of this lab, you will have a working end-to-end data pipeline: raw customer event data → cleaned and transformed records → feature vectors in Feature Store → ready for model training in Lab 3.

---

## Starter Kit

* `northstar-raw-sample.csv` — roughly 163,000 synthetic **transaction** rows across ~11,400 customers, spanning 2025-04-01 to 2026-06-30.
* `glue-scripts/transform.py` — starter Glue ETL script with the schema defined and read/write wired up; the three transform functions are stubbed out
* `glue-scripts/feature_engineer.py` — starter feature engineering script with the Feature Store client wired up; the five feature functions are stubbed out
* `scripts/verify-lab2.sh` — automated rubric verification script.
* `Makefile` — replaces your Lab 1 Makefile.
* `scripts/teardown-lab2.sh` — full teardown.

## Getting Your Repository

Keep working in the repository you created for Lab 1, `cs401r-<your-netid>`.
This lab extends the platform you already built; **do not start a new repository.**

Lab 2 ships **new** starter files. Download the Lab 2 starter kit from Canvas (or copy
them from <https://github.com/byu-cs401r4-f26/cs401r-lab2-template>) into your existing
repository before you begin. Add to what you have — do not replace it.

## Tasks & Point Breakdown

| Task | Points |
| --- | --- |
| Task 1 — Extend Platform Infrastructure Modify your existing Terraform modules and apply the changes to a real AWS account. | 25 |
| Task 2 — Data Ingestion Pipeline Build a new `modules/glue/` module and create the Glue catalog, crawler, and transform ETL job. | 25 |
| Task 3 — Feature Engineering and Labelling Add the feature engineering ETL job to `modules/glue/` and a new `modules/feature_store/` module. | 20 |
| Task 4 — Data Contract and Lineage A data contract is a formal agreement between the team that produces a dataset and the team that consumes it. | 15 |
| Task 5 — Repository Quality | 15 |
| **Total** | **100** |

**Full lab guide, rubrics and worked detail:** [Open the full lab guide](https://byu.instructure.com/courses/38938/files/14455762?wrap=1)

## Submission

Submit your repository URL. Tag the commit you want graded `lab2-submit` and push the tag; the TA grades that tag. The TA will verify your Glue jobs ran and that the Feature Store offline store is populated.

## Submission

Submit a GitHub repository link before the deadline.
A repo that does not clone cleanly loses 20 points automatically.
Never commit AWS credentials — committed secrets = automatic 0.

**Late policy:** 10% per calendar day. Contact instructor before the deadline, not after.
