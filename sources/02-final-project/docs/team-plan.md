<!-- Exported Nov 20, 2026 from the Claude doc "HBM Early Warning: Team Plan" (https://claude.ai/artifact/KDFMDKHxjEhqixLtfGbZ5k). Names per the charter: Teammate 2 = Tom Esplin, Teammate 3 = Caden Annison, Teammate 4 = Joe Gerard. -->

# HBM Early Warning: Team Plan

Nov 20, 2026 · Ramez Gammoh

## Roles at a glance

Each of the four people owns one slice of the system end to end: the code, the design doc sections for it, and their part of the presentation. The workload is about 20 hours each over four weeks, not counting the shared work at the end. The architecture, requirements and timeline are in [HBM Early Warning: Build Plan](https://claude.ai/artifact/1bCGiiwsvCKxcr49jcviTC).

| Role | Person | Builds | Design doc sections | Presentation | Hours (est.) |
|---|---|---|---|---|---|
| Lead and ML engineer | RJ | Scope, data exploration, feature spec and labels, one model per level, thresholds, time-based evaluation against the paper, replay evaluation, model cards, PRR | Executive summary, Model development, Governance framework | Problem, data and model results (4 min) | ~22 |
| Data and platform engineer | Teammate 2 | GitHub repo, shared AWS account and IAM users, Terraform (VPC, S3, SageMaker domain), data contract, Glue feature job, Feature Store, hourly replay with EventBridge, Budgets alert, teardown script | Platform architecture, Data and feature pipeline, Scaling projection, Abstract; assembles the final doc | Architecture and data flow (3 min) | ~20 |
| MLOps and reliability engineer | Teammate 3 | SageMaker Pipeline, Model Registry approval, CI tests in GitHub Actions, serverless endpoint, Evidently drift job, CloudWatch dashboard and alarms, SLOs, runbook | XOps plan, Operating model; owns the slide deck | Pipeline, deployment and monitoring (3 min) | ~20 |
| App and business engineer | Teammate 4 | API Gateway and Lambda routes, Step Functions action workflow, DynamoDB audit log, Streamlit demo app, demo script, Pricing Calculator estimate, ROI model, Metric Pyramid | Deployment strategy, Economic justification; produces the video | Live demo and business case (5 min) | ~22 |

**How to match people to roles:** Teammate 2 should be the one most comfortable with Terraform and AWS from Labs 1 and 2. Teammate 3 fits whoever liked the CI/CD and monitoring labs (4 to 6). Teammate 4 fits whoever is strongest at building apps and writing for a business audience.

**Everyone does:** the charter, review one other person's doc section, rehearse, and take Q&A.

## Week by week

Week 2 is deliberately light because of Thanksgiving, Lab 6 (due Sat Nov 28) and Lab 7 (due Tue Dec 1). All code is done by Thu Dec 10, so the last week goes to writing, the video and rehearsal.

| Week | RJ (lead and ML) | Teammate 2 (data and platform) | Teammate 3 (MLOps and reliability) | Teammate 4 (app and business) |
|---|---|---|---|---|
| **1: Nov 20 to 24** (charter Sat 21) | Submit the charter. Data exploration. Feature spec and labels to Teammate 2 by Sun 22. Laptop baselines per level in MLflow by Tue 24 | Charter: roles and values. GitHub repo with the data. Shared AWS account, IAM users, Budgets alert. Start Terraform from the Lab 1 and 2 modules | Charter: architecture section. Pipeline skeleton (prep, train, evaluate, register) from RJ's scripts. GitHub Actions lint and test | Charter: Gantt chart and first cost estimate. API design (routes and JSON). Streamlit app with fake data |
| **2: Nov 25 to Dec 1** (light week) | Time-based split, thresholds set by action cost, comparison with the paper. Thresholds to Teammate 4. Draft model card | Terraform applied. Glue feature job with data contract gates. Feature Store offline and online loaded | Pipeline runs on Feature Store data and registers 4 models. Recall-floor gate blocks a bad model | Lambda and API Gateway routes against a mock endpoint. Step Functions workflow with approval. DynamoDB audit table |
| **3: Dec 2 to 8** | Replay evaluation: crashes caught, false alarms, lead time. Start the PRR (Tier 2). Draft Model development | Hourly replay with EventBridge. Teardown script. Draft Platform and Data sections and the scaling projection | Approved models on the serverless endpoint. Drift job, CloudWatch dashboard, alarms, SLOs, runbook. Draft XOps and Operating model | App wired to the real endpoint and workflow, demo works end to end. ROI model and Metric Pyramid from RJ's replay numbers |
| **4: Dec 9 to 15** (code complete Thu 10) | Executive summary. Governance section with the PRR and model cards. Rerun final numbers | Assemble the design doc so the action tiers run through every section. Abstract. READMEs and code docs | 15-minute slide deck. Optional class dry run Dec 10. Final runbook | Demo script. Record the 3 to 5 minute video. Deployment strategy and Economic justification sections. Final cost estimate |
| **Final: Dec 16 to 17** | Present problem and model results | Push everything to GitHub, tear down AWS | Present pipeline and monitoring | Run the live demo |

## Handoffs

These are the points where one person blocks another. Make each one a GitHub issue, assigned to the giver with the receiver as reviewer.

| By | From | To | What |
|---|---|---|---|
| Sun Nov 22 | RJ | Teammate 2 | Feature spec: time windows, counts per level, and the label rule |
| Sun Nov 22 | Teammate 4 | Teammate 3 | API contract: the JSON the endpoint takes and returns |
| Tue Nov 24 | RJ | Teammate 3 | Training and evaluation scripts that run on a laptop |
| Tue Nov 24 | RJ | Teammate 4 | Action tiers and the threshold for each level |
| Mon Nov 30 | Teammate 2 | Teammate 3 | Feature Store offline data ready for the pipeline |
| Thu Dec 3 | Teammate 3 | Teammate 4 | Endpoint name and the IAM permission to call it |
| Thu Dec 3 | Teammate 2 | Teammate 4 | Online feature lookups for hourly scoring |
| Sat Dec 5 | RJ | Teammate 4 | Replay results (crashes caught, false alarms) for the ROI |
| Sat Dec 5 | Teammate 4 | Teammate 3 | Scoring logs in S3 for the drift job |
| Thu Dec 10 | Everyone | Teammate 2 | Finished doc sections for assembly |
| Fri Dec 11 | Teammate 4 | Teammate 3 | Demo screenshots for the deck |

## Deliverable owners

Every graded deliverable has one owner who makes sure it ships, even when others contribute. Update the status as work moves.

| Deliverable | Owner | Helpers | Due | Status |
|---|---|---|---|---|
| Project Charter | RJ (submits) | Everyone | Sat Nov 21 | In progress |
| Presentation deck | Teammate 3 | Everyone | Wed Dec 16 | Not started |
| Live demo and demo script | Teammate 4 | RJ | Wed Dec 16 | Not started |
| Design document (all eight layers) | Teammate 2 assembles | Everyone writes their sections | Thu Dec 17 | Not started |
| Architecture and scaling projection | Teammate 2 | Teammate 3 | Thu Dec 17 | Not started |
| Price estimates | Teammate 4 | Teammate 2 | Thu Dec 17 | Not started |
| Documented code in GitHub | Teammate 2 | Everyone | Thu Dec 17 | Not started |
| Video (3 to 5 min) | Teammate 4 | RJ | Thu Dec 17 | Not started |
| Abstract (half page) | Teammate 2 | RJ | Thu Dec 17 | Not started |
| PRR and model cards | RJ | Teammate 3 | Thu Dec 17 | Not started |
| AWS teardown | Teammate 2 | Everyone | Thu Dec 17 | Not started |

## Working agreement

This section can go into the charter as the "values, commitments, communication" item.

- **Own your slice end to end:** each person is accountable for their components working, documented and presented, and asks for help early.
- **Talk:** a team Discord channel. A short standup after class every Tue and Thu through Dec 10, then 15-minute calls on Sat Dec 12 and Mon Dec 14.
- **Track:** a GitHub Projects board with one issue per build step and per handoff.
- **Review:** every pull request reviewed by one teammate within 24 hours, and no direct pushes to main.
- **Blockers:** stuck for more than a day means a post in Discord. A handoff that slips gets a new date posted, and the lead reshuffles work.
- **Decisions:** big choices are written up as short ADRs in the repo, as in Lab 1.
- **AWS:** one shared account run by Teammate 2, an IAM user per person, a Budgets alert, teardown after every session, and no keys or secrets committed (the labs' secret-check script runs in CI).

## Open decisions

Settle these at the first team meeting, ideally before the charter goes in.

- [x] **Who takes which role?** Settled in the charter: Tom (2), Caden (3), Joe (4).
- [ ] **Whose AWS account?** The plan assumes one shared account; the syllabus says each student pays their own charges, so agree how to split the bill.
- [ ] **Where does the demo app run?** A laptop is enough for the Dec 16 demo; hosting it on AWS is optional.
- [ ] **If the team ends up with three people:** Teammate 4's app work moves to Teammate 3, and the economics, video and demo script move to RJ.
