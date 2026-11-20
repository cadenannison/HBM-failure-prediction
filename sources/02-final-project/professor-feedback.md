# Dr. T's feedback on the topic (Nov 20, 2026)

## Verbatim

> With HBM shortages, companies are pushing their infrastructure to its lifetime limits. As a result, I think these kinds of measures will become more important. A 20K dataset isn't very big. Could you find anything larger? Will you have positive and negative examples? Could you generate synthetic data to extend this set? How many memory chips are typically being monitored in a data center? How would this system be rolled out in a live production environment? I like the topic very much. Your challenge will be to convert this into a true production-grade monitoring system. Best, Dr. T.

## Our answers

**1. Could you find anything larger?**
The full Calchas collection behind the paper is about 460M events (roughly 630K per day), but only the 20,391-event sample is public. We searched for other HBM datasets (see `../04-research/prior-work-and-datasets.md`): Summit's HBM2 data is public but has no correctable errors or addresses; the Delta, Polaris, Perlmutter and Cordial studies did not release data; SmartMem is larger but DDR4, not HBM. Decision: stay with Calchas and build scale with a simulator.

**2. Positive and negative examples?**
Yes. The processed Calchas tables label every entity:

| Level | Rows | Positives | Rate |
|---|---|---|---|
| Row | 62,930 | 193 | 0.31% |
| Column | 62,930 | 248 | 0.39% |
| Bank | 62,930 | 427 | 0.68% |
| Server | 105,826 | 543 | 0.51% |

The raw log has 10,470 correctable errors and 9,921 uncorrectable ones (9,587 UEO, 334 UER), so we can also rebuild labels from scratch with a time-based split.

**3. Synthetic data?**
Yes. A fleet simulator (Teammate 2) generates a synthetic data center whose error rates, spatial clustering and CE-to-UE build-up are tuned to the Calchas patterns, and replays real Calchas months inside it. It feeds Kinesis Data Streams like real telemetry would, and the scale test pushes about 630K errors per day, matching the paper's real fleet. Models train on real Calchas data; synthetic data tests scale and the pipeline, and is labeled as synthetic everywhere.

**4. How many memory chips does a data center monitor?**
- An H100 has 5 active HBM3 stacks; a B200 has 8.
- Meta's 16,384-GPU Llama 3 cluster: about 82,000 HBM stacks.
- xAI's Colossus 1: on the order of 1.3 million stacks.
- So the system has to score hundreds of thousands to millions of stacks every hour, which is why ingest goes through Kinesis and scoring runs as serverless batch.

**5. How would it roll out in production?**
Staged, with a PRR gate at each step:
1. **Shadow:** score every hour, take no action, compare predictions with what really failed.
2. **Advisory:** send alerts to operators, who act by hand.
3. **Canary:** automatic row and column actions on 1%, then 10%, then 100% of servers; banks and drains still need a person.
4. **Scheduler integration:** checkpoint and drain hooks wired into the job scheduler.

Rollback is one step (previous model version in the registry), and hardware ECC and remapping stay in place as the fallback.

**6. "Production-grade monitoring system"**
Covered by: data contract checks in Glue, Model Registry approval, CloudWatch dashboards and alarms, Evidently drift checks, SNS paging, SLOs (scores out within 15 minutes of each hour), a DynamoDB audit log of every decision, a runbook and the PRR.
