# PANIC: project overview

**PANIC = Predictive Anomaly Notification for Interposer Components.** Earlier working name: HBM Early Warning.

- Course: BYU CS 401R, Engineering the AI Enterprise, Fall 2026. Instructor: Dr. Scott Toborg ("Dr. T").
- Team: "PANIC! at the Data Center" (Canvas group), 4 people. See `team-and-roles.md`.
- Team repo: `github.com/cadenannison/HBM-failure-prediction` (cloned at `CS 401R\HBM-failure-prediction`).

## Two-sentence description

PANIC predicts uncorrectable HBM memory errors in AI data centers from the correctable errors that come before them, using the public Calchas dataset of real HBM error logs. It runs as a production AWS system that scores the fleet every hour and takes the cheapest safe action, from retiring a memory row automatically to draining a server with human sign-off.

## Pitch

AI training jobs run on thousands of GPUs for weeks, and one uncorrectable HBM error can crash the whole job and throw away hours of cluster time. During Meta's Llama 3 405B run, HBM3 failures caused 72 of 419 unexpected interruptions in 54 days. Today's fixes are reactive: memory gets retired after it has already failed. PANIC watches the correctable errors that build up first, predicts which row, column, bank or server is about to fail, and acts before the crash. Under conservative assumptions that's about $2.9M saved per Llama-scale training run.

## The problem in plain words

- HBM (high bandwidth memory) is the stacked memory sitting next to the GPU on an interposer.
- Small errors (correctable, CE) get fixed by ECC. Big ones (uncorrectable, UE) crash the job.
- Big errors usually follow a build-up of small errors in the same spot. That pattern is learnable.
- With HBM in short supply (expected through at least 2027), companies run hardware to its limits, so catching failures early matters more.

## Action tiers (the idea that ties every layer together)

| Level at risk | Action | Approval |
|---|---|---|
| Row | Retire the row (remap or offline its page) | Automatic |
| Column | Offline the pages the column touches | Automatic |
| Bank | Isolate the bank | Operator approves |
| Server | Checkpoint, then drain the server and move the job | Human sign-off |

## Rollout plan (answer to "how would this go live?")

Shadow (score, no actions) → advisory (alerts only) → canary (actions on 1%, then 10%, then 100% of the fleet) → scheduler integration. A Production Readiness Review (PRR) gates each stage.

## Topic submission (Nov 12, short form)

**TOPIC 1 (first choice):** HBM Early Warning. Predict uncorrectable HBM errors in AI training clusters from correctable-error patterns and act before jobs crash. Data: Calchas HBM error logs (public, GitHub). AWS: Glue, Feature Store, SageMaker Pipelines, Model Registry, API Gateway, Step Functions.

## Related files

- Charter: `group-project-charter.md`, `charter-review.md`
- Plans: `docs/proposal.md`, `docs/build-plan.md`, `docs/team-plan.md`
- Feedback: `professor-feedback.md`
- Decisions: `decisions-log.md`
- Diagrams: `../05-diagrams/`
