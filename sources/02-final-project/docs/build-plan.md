<!-- Exported Nov 20, 2026 from the Claude doc "HBM Early Warning: Build Plan" (https://claude.ai/artifact/1bCGiiwsvCKxcr49jcviTC). Embedded diagrams not included; see ../../05-diagrams/. Course paths below refer to the old "course-content" folder, now ../../01-course-material/. -->

# HBM Early Warning: Build Plan

Nov 20, 2026 · Ramez Gammoh

The course asks for a working end-to-end system on AWS with a demo app, a video and code in GitHub, not just a design document, and the Project Charter is due Nov 21, 2026 at 11:59 PM.

## What the course requires

The Final Project is 30% of the course grade, and only three things left are graded: the charter, the presentation and the final submission. Dr. T's Nov 17 announcement says the other milestones are suggestions.

| Deliverable | Due | Graded | What it is |
|---|---|---|---|
| Team Sign-Up | Nov 5 | 5 pts | Done |
| Team Project Topics | Nov 12 | 5 pts | Done |
| **Group Project Charter** | **Sat Nov 21, 11:59 PM** | 5 pts | Title, vision, roles, values and communication, architecture diagram, cost estimate (optional now), Gantt chart with milestones |
| Model pipeline complete | Nov 24 | Suggested | From the Final Project slides |
| Code complete | Dec 10 | Suggested | Last class; optional presentation dry run |
| **Presentation** | **Wed Dec 16, 3 to 6 PM, 1230 TRNB** | Part of 90 pts | About 20 minutes: 15 to present, 5 for Q&A, with a live demo |
| **Final submission** | **Thu Dec 17, 11:59 PM** | Part of 90 pts | Into the group GitHub: architecture and scaling projection, price estimates, documented code, demo script, presentation, 3 to 5 minute video, half-page abstract, and the design document covering all eight layers |

Watch the overlap with labs: Lab 6 is due Sat Nov 28 and Lab 7 is due Tue Dec 1, so the build has to fit around both.

## Minimum requirements, mapped to our system

Every minimum requirement on slide 4 of the Final Project deck maps to one piece of HBM Early Warning. Three services go beyond the labs (SageMaker Pipelines, API Gateway, Step Functions), which covers "extends in-class learning".

| Requirement (slide 4) | How HBM Early Warning meets it | AWS service | New vs labs |
|---|---|---|---|
| End to end, data ingest through model monitoring | Raw HBM error log replayed into S3, turned into features, scored hourly, monitored | S3, Glue, SageMaker, CloudWatch | Reuses Labs 1, 2, 6 |
| Pipeline services for data prep, training, evaluation, deployment | One pipeline: prep, train one XGBoost model per level, evaluate against a recall floor, register | SageMaker Pipelines | New (labs used GitHub Actions or CodePipeline) |
| Model Registry | One model package group per level, human approval before deploy | SageMaker Model Registry | Labs 4 and 5 |
| Feature Store | Feature groups for row, column, bank and server, offline for training and online for scoring | SageMaker Feature Store | Lab 2 |
| Model Monitoring | Drift on CE rate, temperature and prediction mix; dashboard and alarms | Evidently drift job, CloudWatch | Lab 6 |
| API Gateway | Endpoints the demo app calls: fleet status, risk scores, pending actions, approve or reject | API Gateway, Lambda, SageMaker Serverless Inference | New (required) |
| Scale to many users (documented, not built) | Streaming telemetry from 100K+ servers, partitioned by data center; one endpoint per HBM generation | Kinesis Data Streams (design only) | Doc only |
| At least one unique service | Action workflow: retire rows automatically, wait for operator approval on banks, require human sign-off before draining a server | AWS Step Functions (task-token approval) | New |
| Demo app and UI, with demo script | Fleet health dashboard: replay a day of errors, watch risk scores rise, approve a drain | Streamlit app calling API Gateway | New |

> Update after Dr. T's feedback (Nov 20): Kinesis Data Streams and a synthetic fleet simulator moved from "design only" into the build. See the architecture and Gantt PNGs in `05-diagrams`.

## Architecture

Raw error logs become features, features train four models, and every hour the scores go to a workflow that picks the cheapest fix and waits for a human on expensive ones. This diagram doubles as the charter's architecture diagram.

*[Diagram: system architecture, 4 layers, 13 components]*

The demo app talks only to API Gateway, so the same routes could serve a real operations console. The scaling projection (documented, not built) swaps the hourly replay for Kinesis streams from the whole fleet.

## Timeline

The build runs four weeks around Lab 6 and Lab 7, finishing the code by Dec 10 so the last week goes to the document, video and rehearsal. This is the charter's Gantt chart.

*[Diagram: build timeline, Nov 20 to Dec 17]*

The tightest stretch is Nov 28 to Dec 1, when both labs are due while the AWS pipeline is being built, so the laptop work in the first week has to land on time.

## Build steps

Build on laptops first, then move to AWS. Each step reuses a lab where it can. Owners are the four roles in the Team Plan: Lead and ML (RJ), Data and platform, MLOps and reliability, App and business.

### Phase A: Charter (Nov 20 to 21)

1. **Write and submit the charter.** Everyone; the lead submits. Done when: it's on Canvas by Sat Nov 21, 11:59 PM.

### Phase B: Data and models on a laptop (Nov 20 to 24)

2. **Set up the repo and data.** Data and platform. Group GitHub repo, the Calchas data, a Python environment. Done when: the check script prints 20,391 raw rows.
3. **Explore the errors.** Lead and ML. Done when: an EDA notebook and a short summary of what comes before an uncorrectable error.
4. **Build features from the raw log.** Lead and ML, with Data and platform. Windowed CE and UE counts per row, column, bank and server; label = a UER in the next window; split by time. Done when: the features roughly match the paper's ready-made tables.
5. **Train baselines.** Lead and ML. One XGBoost model per level, a threshold per level set by the cost of its action, every run in MLflow. Done when: F1 per level is recorded next to the paper's results (course milestone: model pipeline complete, Nov 24).

### Phase C: AWS platform and pipeline (Nov 23 to Dec 1)

6. **Stand up AWS with Terraform.** Data and platform. Reuse the Lab 1 and Lab 2 modules: VPC, S3, IAM roles, SageMaker domain, Glue, Feature Store. Done when: apply succeeds and a verify script passes.
7. **Glue feature job and Feature Store.** Data and platform. Done when: every entity is in the offline store and an online lookup works.
8. **SageMaker Pipeline.** MLOps and reliability. Prep, train on spot, evaluate, register. Done when: one run registers four models, and a deliberately bad model is blocked by the recall floor.

### Phase D: Serving and actions (Nov 30 to Dec 5)

9. **Deploy behind API Gateway.** MLOps and reliability puts the approved models on a serverless endpoint; App and business adds API Gateway and Lambda routes for fleet status, scores and actions. Done when: a request returns risk scores.
10. **Step Functions action workflow.** App and business. Rows retire automatically; banks wait for an operator; drains wait for a human sign-off; every decision lands in an audit table. Done when: a drain pauses for approval and the audit row names the approver.
11. **Replay and hourly scoring.** Data and platform. EventBridge triggers scoring as the raw log is replayed hour by hour. Done when: replaying one month produces actions.

### Phase E: Monitoring, app and business case (Dec 3 to 10)

12. **Monitoring.** MLOps and reliability. Evidently drift job, CloudWatch dashboard, alarms and a runbook, as in Lab 6. Done when: injected drift fires an alarm.
13. **Demo app.** App and business. A Streamlit fleet dashboard calling API Gateway, plus a demo script. Done when: the full demo runs in under 5 minutes.
14. **Economics.** App and business. AWS Pricing Calculator estimate, crash-cost ROI model and the Metric Pyramid, as in Lab 7. Done when: cost per 1,000 scores and net savings per training run come from one spreadsheet.
15. **Governance and PRR.** Lead and ML, with MLOps and reliability. Fill the course's PRR template at Tier 2 (internal, human in the loop), plus model cards. Done when: every PRR item links to evidence (course milestone: code complete, Dec 10).

### Phase F: Write, record, present (Dec 10 to 17)

16. **Design document.** Everyone drafts their layers; Data and platform assembles it, with the scaling projection. Done when: all eight layers are covered and tell one story.
17. **Abstract, video and deck.** Abstract by Data and platform, video by App and business, deck by MLOps and reliability. Half-page abstract; a 3 to 5 minute video for a CS student outside ML; a 15-minute deck. Done when: all three are in the repo.
18. **Rehearse and present.** Everyone. Optional dry run in class Dec 10; present Wed Dec 16, 3 to 6 PM, 1230 TRNB. Done when: the run-through fits 15 minutes.
19. **Submit and tear down.** Data and platform. Push everything to the group GitHub, then destroy AWS resources. Done when: submitted by Thu Dec 17, 11:59 PM and the AWS bill stops growing.

## Charter checklist (due Sat Nov 21)

The charter assignment asks for seven items, and most of them come straight from this plan.

- [ ] **Project title:** HBM Early Warning: predicting memory failures before they crash AI training jobs
- [ ] **Vision:** the problem (one HBM error crashes multi-day training jobs), the goal (predict and fix failing memory first), and why it matters (Meta's Llama 3 run had 72 interruptions from HBM failures in 54 days). Reuse the proposal's executive summary
- [ ] **Roles and responsibilities:** the four roles in Build steps, with a name on each
- [ ] **Values, commitments, communication:** for example, Discord for chat, a standup after class every Tue and Thu, GitHub issues for tasks, every pull request reviewed by one teammate, AWS torn down after every session
- [ ] **Architecture diagram and description:** the Architecture section of this plan
- [ ] **Cost estimate (optional now, required at the end):** a first pass in the AWS Pricing Calculator
- [ ] **Project plan with Gantt chart and milestones:** the Timeline section of this plan

## How we get graded

The syllabus gives the weights, and the Final Project slides add five grading elements. One plan covers both.

| What's graded | Weight | Source | How we hit it |
|---|---|---|---|
| Innovation and technical depth | 40% | Syllabus | Four-level prediction on real HBM data, a time-based split, a benchmark against the published paper, and the Step Functions approval workflow |
| Integration and coherence across layers | 30% | Syllabus | The action tiers run through every layer: they set model thresholds, what deployment automates, what monitoring alerts on, what economics prices and who signs off |
| Business and executive communication | 20% | Syllabus | Dollar impact per training run, the Metric Pyramid from model metrics up to business outcomes, a tight abstract and video |
| Presentation | 10% | Syllabus | A live demo where a drain waits for approval, rehearsed to 15 minutes |
| Meets minimum requirements | Not weighted | Slides | Every row of the requirements table above, checked off |
| Extends in-class learning | Not weighted | Slides | SageMaker Pipelines, API Gateway and Step Functions are all new beyond the labs |
| Documentation | Not weighted | Slides | Documented code, READMEs, model cards and the filled PRR |
| Complexity | Not weighted | Slides | Four models, an approval workflow, replay, drift monitoring |
| Coolness factor | Not weighted | Slides | Real HBM errors from production data centers replayed live, with failures predicted before they happen |

## Cost and teardown

The syllabus expects $50 to $100 of AWS charges per student, and each student pays their own, so the build must stay cheap and get torn down after every session.

- **Watch the usual leaks from the labs:** NAT gateways bill by the hour, SageMaker Studio apps keep running when you close the tab, and Glue and Feature Store bill while in use.
- **Design for low cost:** a serverless endpoint that scales to zero, training on spot (as in Lab 4), and scoring as an hourly batch instead of an always-on service.
- **Guardrails:** an AWS Budgets alert per account, a project tag on every resource, and a teardown script run at the end of every working session.
- **Two cost numbers for the final submission:** what our demo actually cost, and a Pricing Calculator estimate for a production fleet. The second one feeds the ROI.

## Sources

All from the CS 401R Canvas course (now in `sources\01-course-material`, start with its README).

- Final Project requirements, milestones and grading elements: `final-project-slides.md` (from `files/final-project/Final_Project_F26.pptx`)
- Charter, topics and sign-up instructions: `assignments/final-project/`
- Rubric, due dates, lab schedule and AWS cost expectation: `syllabus.md`
- Charter due-date change and "other milestones are suggestions": `announcements.md`, Nov 17 post
- Production Readiness Review: `prr-template.md` and `prr-guide.md`
- Services already used in Labs 1 to 7: `files/labs/handouts/`
- Metric Pyramid and SLOs: `text/book/Ch26-Metrics-Benchmarks-Guardrails.md`, `Ch30-Measuring-Business-Value.md`, `Ch28-Reliability-Engineering.md`
- Data: [Calchas HBM error dataset](https://github.com/wrl297/Calchas), Wu et al., USENIX ATC 2024
