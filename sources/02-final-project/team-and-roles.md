# Team and roles

From the charter (Nov 20). The diagrams and plan docs use "Teammate 1 to 4"; this is the mapping.

| Diagram label | Name | Role |
|---|---|---|
| Teammate 1 | RJ Gammoh | Lead and ML |
| Teammate 2 | Tom Esplin | Data and platform |
| Teammate 3 | Caden Annison | MLOps and reliability |
| Teammate 4 | Joe Gerard | App and business |

About 20 hours each over four weeks, plus shared work at the end.

## What each role does

**Teammate 1, RJ: Lead and ML**
- Builds: data exploration, feature spec and labels, one model per level (row, column, bank, server), thresholds set by action cost, time-based evaluation against the Calchas paper, replay evaluation (crashes caught, false alarms, lead time), model cards, PRR.
- Writes: executive summary, model development, governance.
- Presents: problem, data and model results (about 4 min). Submits the charter.

**Teammate 2, Tom: Data and platform**
- Builds: GitHub repo, AWS account and IAM users, Terraform (VPC, S3, SageMaker domain), Budgets alert, data contract, Glue feature job, Feature Store, fleet simulator, Kinesis stream, hourly EventBridge replay, scale test, teardown script.
- Writes: platform architecture, data and feature pipeline, scaling projection, abstract; assembles the design doc.
- Presents: architecture and data flow (about 3 min).

**Teammate 3, Caden: MLOps and reliability**
- Builds: SageMaker Pipeline (prep, train, evaluate, register), Model Registry approval, GitHub Actions CI, serverless SageMaker endpoint, Evidently drift job, CloudWatch dashboard and alarms, SLOs, runbook.
- Writes: XOps plan, operating model; owns the slide deck.
- Presents: pipeline, deployment and monitoring (about 3 min).

**Teammate 4, Joe: App and business**
- Builds: API contract, Lambda and API Gateway routes, Step Functions action workflow, SNS alerts, DynamoDB audit log, Streamlit fleet dashboard, demo script, Pricing Calculator estimate, ROI model, Metric Pyramid.
- Writes: deployment strategy, economic justification; produces the 3 to 5 minute video.
- Presents: live demo and business case (about 5 min).

**Everyone:** charter, review one other person's doc section, rehearse, take Q&A.

## Working agreement (charter values)

- Values: independence, hard work, accountability, ownership.
- Weekly standup; Discord for day-to-day; progress tracked against the Gantt chart.
- Suggested extras from the Team Plan: one GitHub issue per build step and handoff, every pull request reviewed by one teammate within 24 hours, no direct pushes to main, short ADRs for big decisions, AWS torn down after every session, no secrets committed.

## Key handoffs

| By | From | To | What |
|---|---|---|---|
| Sun Nov 22 | RJ | Tom | Feature spec: time windows, counts per level, label rule |
| Sun Nov 22 | Joe | Caden | API contract (JSON in and out) |
| Tue Nov 24 | RJ | Caden | Training and evaluation scripts that run on a laptop |
| Tue Nov 24 | RJ | Joe | Action tiers and thresholds per level |
| Mon Nov 30 | Tom | Caden | Feature Store offline data ready |
| Thu Dec 3 | Caden | Joe | Endpoint name and IAM permission |
| Thu Dec 3 | Tom | Joe | Online feature lookups for hourly scoring |
| Sat Dec 5 | RJ | Joe | Replay results for the ROI |
| Sat Dec 5 | Joe | Caden | Scoring logs in S3 for the drift job |
| Thu Dec 10 | Everyone | Tom | Finished doc sections |
| Fri Dec 11 | Joe | Caden | Demo screenshots for the deck |

## Open decisions

- Whose AWS account, and how to split the bill (syllabus: each student pays their own, about $50 to $100).
- Where the demo app runs (a laptop is enough for Dec 16).
