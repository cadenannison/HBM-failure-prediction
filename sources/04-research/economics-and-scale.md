# Economics and scale

## Cost of one crash

C = N × t × p

- N = accelerators in the job (16,384 H100 for Meta's Llama 3 405B run)
- t = hours of cluster time lost per crash (assumed 1 hour: rework since the last checkpoint plus restart)
- p = price per GPU-hour (assumed $4.00; specialist clouds about $2 to $4.50, hyperscalers $6.88 and up)

C = 16,384 × 1 × $4 = **$65,536 per crash**. With 72 HBM crashes per run: **$4.72M per run**.

## Net savings

Net savings = H·r·(C − cₐ) − H·r·((1 − P)/P)·cₐ

- H = HBM crashes per run (72), r = recall (74.6%), P = precision (58.0%), cₐ = cost of acting on a warning (6 minutes of cluster time, worst case: on-demand checkpoint and drain)

| Result | Value |
|---|---|
| Crashes caught early | 54 of 72 |
| Saved on caught crashes | $3.17M |
| False alarms | 39, costing $0.25M |
| **Net savings per run** | **$2.91M** (about 62% of HBM crash cost) |

| Scenario | Net savings per run |
|---|---|
| Baseline ($4/GPU-hour, 58% precision) | $2.91M |
| GPU-hour at $2 | $1.46M |
| GPU-hour at $7 | $5.10M |
| Precision falls to 30% | $2.35M |

It holds even if precision halves, because a false alarm costs about a tenth of a crash. These are illustrative; the final ROI should use our own replay numbers (crashes caught, false alarms).

## How many chips does a data center watch?

| Hardware | HBM stacks |
|---|---|
| One H100 | 5 (HBM3) |
| One B200 | 8 |
| Meta's 16,384-GPU Llama 3 cluster | ~82,000 |
| xAI Colossus 1 | ~1.3 million |

Error volume: Calchas's full fleet logged about 460M events, roughly 630K per day. Our scale test targets that rate.

## AWS cost for the project

- Syllabus expects $50 to $100 per student; each student pays their own.
- Keep it cheap: serverless endpoint (scales to zero), spot training, hourly batch scoring, Budgets alert, teardown after every session.
- Final submission needs two numbers: what the demo actually cost, and a Pricing Calculator estimate for a production fleet.
