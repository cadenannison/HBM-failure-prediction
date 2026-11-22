# Decisions log

What we decided and why, in order.

| When | Decision | Why |
|---|---|---|
| Late Oct | Explored ideas: wafer yield, tool maintenance, hardware validation | Wanted a topic in semiconductors / hardware |
| Oct 30 | Chose HBM failure prediction ("HBM Early Warning") | Verified the data exists and is solid first: Calchas is public, real, labeled and has published benchmarks |
| Oct 30 | Rejected wafer-map (WM-811K) and tool-maintenance (PHM 2018) data | Wafer maps are about wafer defects, not memory errors; tool data didn't fit a data-center system |
| Nov 5 | Team sign-up done (Canvas group "PANIC! at the Data Center") | |
| Nov 6 | Proposal written | |
| Nov 12 | Topic submitted | |
| Nov 20 | A working AWS system is required, not just a design doc | Final Project slides (slide 4) ask for an end-to-end system, demo app and video |
| Nov 20 | Considered SmartMem (Kaggle, DDR4) as a second dataset, then **dropped it** | It's DDR4 not HBM, would need a second pipeline, and doesn't answer the HBM question |
| Nov 20 | **Calchas only**, plus a synthetic fleet simulator for scale | Dr. T asked for more data; simulator gives scale without mixing memory types |
| Nov 20 | Added Kinesis Data Streams for live ingest | Real fleets stream errors; shows production scale |
| Nov 20 | Staged rollout: shadow → advisory → canary → scheduler | Answers "how would this roll out live?" |
| Nov 20 | Renamed to **PANIC** (Predictive Anomaly Notification for Interposer Components) | Team name tie-in |
| Nov 20 | Roles: RJ lead and ML, Tom data and platform, Caden MLOps and reliability, Joe app and business | Charter |
| Nov 20 | New AWS services beyond the labs: Kinesis, SageMaker Pipelines, API Gateway, Step Functions | "Extends in-class learning" grading element |
| Nov 21 | Plan for teammates to assume scoped cross-account roles in the shared hosting account using their own IAM users with MFA | Reuse existing sign-ins and MFA; avoid duplicate teammate users in the hosting account. Hosting account pays project charges; reimbursement remains open. Details: [IAM access plan](docs/iam-access-plan.md). |
| Nov 21 | Define the three permission baselines in a separate Terraform IAM stack | Review explicit grants before deployment; platform retains IAM/shared infrastructure, while teammates manage their project components. See [Terraform permissions matrix](../../infra/iam/README.md). No apply performed. |
| Nov 21 | Allow RJ's human role to upload/replace project S3 raw data and features | Supports ML data preparation and corrections. Caden/Joe do not gain those writes; object deletion stays excluded. Terraform updated; no apply performed. |
| Nov 21 | Delegate each teammate's assigned execution-role inline permissions to that teammate | Owners can maintain runtime permissions themselves within a platform-controlled boundary. Human roles, execution-role trust/boundaries/creation, and cross-owner changes remain with platform. New direct human access or a wider boundary still needs a platform Terraform change. No apply performed. |
| Nov 21 | Broaden development access within each owner's planned service families | Implement Studio assignment templates, RJ/Caden cloud job variants and MLflow, Caden/Joe ECR ownership, and central runtime boundaries in Terraform. Naming patterns cover future matching resources. IAM administration, billing, networking, API IDs, and execution-role ownership remain controlled. No apply performed. |

## Model choices

- One classifier per level (row, column, bank, server). XGBoost planned; baseline was a random forest.
- Train on earlier months, test on later months (time-based split), because the processed tables have no timestamps.
- Threshold per level set by the cost of its action, not by F1 alone.
- Benchmark: Calchas paper F1 of row 0.78, column 0.79, bank 0.70, server 0.42.
- Quick baseline (random forest, random 70/30 split, untuned): row-level F1 about 0.69. Script: `../03-dataset/baseline.py`.
