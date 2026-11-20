<!-- Exported Nov 20, 2026 from the Claude doc "HBM Early Warning: Project Proposal" (https://claude.ai/artifact/GgGmF9MPvpHVt8BfD95xmz). Two embedded diagrams are not included; see ../../05-diagrams/. -->

# HBM Early Warning: Project Proposal

Nov 6, 2026 · Ramez Gammoh · CS 401R Final Project

## Executive summary

HBM Early Warning predicts uncorrectable HBM errors in AI training clusters and acts before they crash multi-day jobs. It reads the correctable errors that come first, scores risk at row, column, bank and server level, and picks the cheapest fix that works.

The problem is real and measurable. During Meta's 54-day Llama 3 405B training run on 16,384 H100 GPUs, HBM3 failures caused 72 of 419 unexpected interruptions (17.2%).

The pieces exist, but not together. Huawei's Calchas showed HBM failures can be predicted offline, and Intel's Memory Failure Prediction runs in production for standard server DIMMs. We design the production system for HBM, estimated to save about $2.9M per Llama-scale run, built on a public dataset of 20,391 real HBM error events from 8 data centers, with published benchmarks to beat.

## Problem

One uncorrectable HBM error can stop a training job that spans thousands of accelerators. The job restarts from its last checkpoint, so every accelerator-hour since then is lost, plus the time to restart.

This happens often at scale. Meta's Llama 3 405B run hit an unexpected interruption roughly every 3 hours, and 72 of the 419 unexpected interruptions were HBM3 memory failures ([Tom's Hardware](https://www.tomshardware.com/tech-industry/artificial-intelligence/faulty-nvidia-h100-gpus-and-hbm3-memory-caused-half-of-the-failures-during-llama-3-training-one-failure-every-three-hours-for-metas-16384-gpu-training-cluster)).

Today's protection is mostly reactive. Error correction (ECC) fixes small errors, and bad memory is remapped or offlined only after an uncorrectable error has already happened. By then the job has usually crashed.

The opportunity: uncorrectable errors often follow a build-up of correctable errors on the same row, column or bank. A model that reads those patterns can act first.

## Prior work and what is new

HBM failure prediction has been shown offline, and memory failure prediction runs in production for standard DIMMs, but no published system does both for HBM.

| Work | Memory | What it does | In production? | Gap we fill |
|---|---|---|---|---|
| [Calchas](https://usenix.org/system/files/atc24-wu-ronglong.pdf) (Huawei, USENIX ATC 2024) | HBM2 on AI accelerators | Predicts failures at row, column, bank and server level; average precision 58.0%, recall 74.6% | No. Evaluated offline on historical logs | No action loop, rollout, monitoring or economics |
| [Intel Memory Failure Prediction](https://www.intel.com/content/dam/www/central-libraries/us/en/documents/2023-12/intel-memory-failure-prediction-improves-reliability-meituan.pdf) | DDR server DIMMs | Scores memory health from correctable errors; drives page offlining, migration and DIMM replacement | Yes. A Meituan test on several thousand servers projected up to 40% fewer hardware-caused crashes (vendor case study) | Does not cover HBM |
| Remapping and page offlining | HBM and DRAM | Retires bad memory after an uncorrectable error is seen | Yes | Reactive: the job has already crashed |

Our contribution is the production design for HBM: predictions at four levels, each tied to an action, plus a staged rollout, monitoring, crash-cost economics and governance.

## Proposed system

Every hour, the system scores each row, column, bank and server that has logged recent errors, then applies the cheapest action that removes the risk. Cheap actions run automatically; expensive ones need a person.

*[Diagram: how it works, logs to features to risk models to actions]*

Each warning goes to the cheapest fix for its level, and confirmed outcomes feed the next retraining.

| Level at risk | Action | What it costs | Approval |
|---|---|---|---|
| Row | Retire the row (remap it or offline its page) | A few KB of memory, no downtime | Automatic |
| Column | Offline the pages the column touches | A small slice of memory, no downtime | Automatic |
| Bank | Isolate the bank (spare it where hardware allows, else offline its pages) | More memory lost, no restart | Operator approves |
| Server | Trigger a checkpoint, then drain the server and move the job | Minutes of job time and one node out of service | Human sign-off |

The on-demand checkpoint matters most. Even when a crash cannot be avoided, saving state first means the job loses minutes instead of everything since its last scheduled checkpoint.

## Data

We use the public Calchas HBM error dataset, which we have already downloaded, profiled and trained a quick baseline on.

| Item | Value |
|---|---|
| Source | [Calchas repository](https://github.com/wrl297/Calchas), released with the USENIX ATC 2024 paper |
| Access | Public git clone, 24 MB, no account needed |
| Raw error events | 20,391: 10,470 correctable (CE) and two classes of uncorrectable error (9,587 UEO, 334 UER) |
| Coverage | 8 data centers, 50 servers, about two years of logs |
| Location per event | Stack, channel, bank group, bank, row, column, timestamp |
| Ready-made training tables | Row, column and bank level: 62,930 rows each. Server level: 105,826 rows |
| Positive rate | 0.3% to 0.7% per level |
| Extra signals | Temperature and power (ready-made tables only) |
| Published F1 to beat | Row 0.78, column 0.79, bank 0.70, server 0.42 |

Caveats we design around:

- The ready-made tables have no timestamps or server IDs, so an honest time-based split needs features rebuilt from the raw logs. That rebuild is our feature pipeline.
- The data covers 50 servers and HBM2, so HBM3 fleets would need retraining before rollout.
- No license is stated. We cite the paper and use the data for coursework only.
- An untuned random forest on the ready-made tables already reaches row-level F1 0.69, so the signal is there.

## System design across the eight layers

One decision ties every layer together: the action tiers. They set the thresholds in modeling, what deployment automates, what operations alerts on, what economics prices and what governance signs off.

| Layer | Key design decisions | Built with |
|---|---|---|
| Platform architecture | All infrastructure as code in a private VPC. Least-privilege roles: DataEngineer, MLEngineer, ModelMonitor and a read-only FleetOps role. Choices recorded in an ADR | Terraform, S3, VPC-only SageMaker |
| Data and feature pipeline | Data contract on raw error logs (schema, valid ECC types, valid addresses, dedupe). Windowed CE and UE counts per row, column, bank and server. Quality gates fail the job on bad data | Glue, Feature Store (offline for training, online for scoring) |
| Model development | One classifier per level. Train on earlier months, test on later ones. Threshold per level set by the cost of its action. Benchmarked against the paper | scikit-learn, XGBoost, MLflow, model card |
| XOps plan | A model is promoted only if it meets the recall floor and does not regress against the champion. Retraining on a schedule and on drift. Human approval in the registry | SageMaker Pipelines, model registry, CI tests |
| Deployment strategy | Hourly batch scoring, since failures build over hours. Shadow, then advisory, then automatic for row and column actions only. One-step rollback | SageMaker batch jobs, registry versions |
| Operating model | Scores out within 15 minutes of each hour. Drift monitors on CE rate, temperature and prediction mix. Precision and recall from late-arriving labels. Runbook with hardware ECC and remapping as the fallback | CloudWatch alarms, ModelMonitor role |
| Economic justification | Cost of a crash against the cost of each action, with sensitivity on false alarms (next section) | Cost model spreadsheet |
| Governance framework | Automation level matches action cost. Human sign-off for server drains. Audit trail of every score, model version, action and approver. Model card on every release | IAM, CloudTrail, registry approvals |

## Economic case

Under the assumptions below, the system saves about $2.9M per Llama-scale training run, roughly 62% of what HBM crashes cost today. These are illustrative figures that the final design doc will refine.

| Input | Value | Basis |
|---|---|---|
| Accelerators in the job | 16,384 H100 | Meta Llama 3 405B run |
| HBM-caused crashes per run | 72 in 54 days | Meta Llama 3 405B run |
| Price per GPU-hour | $4.00 | Assumed. Specialist clouds list about $2 to $4.50, hyperscalers $6.88 and up ([IntuitionLabs](https://intuitionlabs.ai/articles/h100-rental-prices-cloud-comparison)) |
| Cluster time lost per crash | 1 hour | Assumed: rework since the last checkpoint plus restart |
| Cost of acting on a warning | 6 minutes of cluster time | Assumed worst case: on-demand checkpoint and drain |
| Recall and precision | 74.6% and 58.0% | Calchas paper averages |

```latex
\text{Net savings} = H \, r \, (C - c_a) \;-\; H \, r \, \frac{1 - P}{P} \, c_a, \qquad C = N \, t \, p
```

Here H is HBM crashes per run, r recall, P precision, C the cost of one crash, c_a the cost of acting on a warning, N accelerators, t hours lost and p the price per GPU-hour.

| Result | Value |
|---|---|
| Cost of one HBM crash | $65,536 |
| HBM crash cost per run today | $4.72M |
| Crashes caught early | 54 of 72 |
| Saved on caught crashes | $3.17M |
| False alarms | 39, costing $0.25M |
| Net savings per run | $2.91M |

| Scenario | Net savings per run |
|---|---|
| Baseline ($4 per GPU-hour, 58% precision) | $2.91M |
| GPU-hour at $2 | $1.46M |
| GPU-hour at $7 | $5.10M |
| Precision falls to 30% | $2.35M |

The case holds even if precision halves, because a false alarm costs a tenth of a crash. The system itself runs on hourly CPU batch jobs and a few gigabytes of logs, so staffing is its main cost, and one large run's savings covers it.

## Success metrics and evaluation

We judge the project on whether the models work on an honest time-based split and whether the warnings arrive early enough to act.

| Metric | Target | Why it matters |
|---|---|---|
| F1 per level, time-based test | Within 0.05 of the paper (row 0.78, column 0.79, bank 0.70, server 0.42) | Shows the models hold up without leakage |
| Server-level recall | At least 70% | Server failures are the ones that crash jobs |
| Precision on server drains | At least 50% | Keeps false drains affordable; the economics still hold at 30% |
| Warning lead time | At least 1 hour before the failure | Hourly scoring can only act on earlier warnings |
| Scoring SLO | Scores out within 15 minutes of each hour, 99% of hours | Late scores are useless scores |
| Data quality | Every run passes the data contract or fails loudly | Bad logs never reach a model |

How we evaluate:

1. Train on earlier months of the raw logs and test on later months.
2. Compare per-level F1 against the paper's published results.
3. Replay the raw logs hour by hour through the full pipeline, as a shadow-mode simulation, to count crashes caught, false alarms and lead time.
4. Feed those counts into the cost model in place of the assumed recall and precision.

## Risks and mitigations

The biggest risk is that a small public dataset overstates how well the models transfer to a real fleet, so nothing acts on its own until shadow mode proves it.

| Risk | Impact | Mitigation |
|---|---|---|
| Dataset is small (50 servers) and HBM2 only | Models may not transfer to HBM3 fleets | Retrain per HBM generation; shadow mode before any action |
| Time-based split scores below the paper | Targets missed | Report both splits and explain the gap; set thresholds by action cost, not F1 alone |
| False server drains | Operators stop trusting alerts | Human sign-off on drains; precision floor; track how often operators override |
| Missed failures | Crashes still happen | Hardware ECC and remapping stay in place; the system only adds protection |
| Drift from new firmware, workloads or temperatures | Silent model decay | Drift monitors with retraining triggers |
| Ready-made tables lack IDs and timestamps | Temperature and power cannot join the raw-log features | Two modeling tracks; production design specifies the telemetry join |
| Lab AWS costs run over | Budget burned on idle resources | Tear down with scripts after every session |
| Eight layers for 3 to 4 people | A shallow document | One owner per workstream; build the core path (pipeline, models, batch scoring, replay) and keep the rest at design depth |

## Plan and milestones

We build one layer group per week and finish the full draft on Dec 11, leaving the last week for the deck, rehearsal and review.

*[Diagram: project plan, 5 build stages, 3 course deadlines]*

The models stage runs through Thanksgiving week, so it gets extra days. Owners draft their doc sections as each stage finishes, not at the end.

## Team and roles

Each workstream has one owner, who also drafts the doc sections that workstream produces. Ramez Gammoh leads and owns modeling; the other three owners come from the team roster.

| Role | Owns | Doc sections |
|---|---|---|
| Lead and modeling | Scope, data exploration, models per level, replay evaluation, model card | Problem, model development, success metrics |
| Data and platform | Terraform, IAM roles, data contract, Glue feature job, Feature Store | Platform architecture, data and feature pipeline |
| XOps and deployment | Registry, retraining pipeline, CI tests, batch scoring, monitoring | XOps plan, deployment strategy, operating model |
| Economics and governance | Cost model, sensitivity analysis, governance framework, final assembly | Economic justification, governance framework, executive summary |

## Sources

- [Removing Obstacles before Breaking Through the Memory Wall: A Close Look at HBM Errors in the Field](https://usenix.org/system/files/atc24-wu-ronglong.pdf), Wu et al., USENIX ATC 2024
- [Calchas repository and dataset](https://github.com/wrl297/Calchas)
- [Faulty Nvidia H100 GPUs and HBM3 memory caused half of the failures during Llama 3 training](https://www.tomshardware.com/tech-industry/artificial-intelligence/faulty-nvidia-h100-gpus-and-hbm3-memory-caused-half-of-the-failures-during-llama-3-training-one-failure-every-three-hours-for-metas-16384-gpu-training-cluster), Tom's Hardware
- [Intel Memory Failure Prediction improves reliability at Meituan](https://www.intel.com/content/dam/www/central-libraries/us/en/documents/2023-12/intel-memory-failure-prediction-improves-reliability-meituan.pdf), Intel case study
- [H100 rental prices compared](https://intuitionlabs.ai/articles/h100-rental-prices-cloud-comparison), IntuitionLabs, updated October 2026
