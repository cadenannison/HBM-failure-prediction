# Prior work and other datasets

Research done Oct 30 to Nov 20, 2026, to answer "has this been done?" and "is there more data?"

## Has this been built before?

Partly. Prediction has been shown offline for HBM, and memory failure prediction runs in production for regular server memory, but nobody has published a production HBM system with an action loop.

| Work | Memory | What it does | In production? | What's missing |
|---|---|---|---|---|
| Calchas (Huawei, USENIX ATC 2024) | HBM2 | Predicts failures at row, column, bank, server level; precision 58.0%, recall 74.6% | No, offline on historical logs | Action loop, rollout, monitoring, economics |
| Intel Memory Failure Prediction (Meituan case study) | DDR DIMMs | Scores memory health from correctable errors; drives page offlining, migration, replacement | Yes; projected up to 40% fewer hardware-caused crashes | Doesn't cover HBM |
| Remapping and page offlining | HBM and DRAM | Retires memory after an uncorrectable error | Yes | Reactive: the job already crashed |

## Other datasets we checked

| Dataset | What it is | Usable for PANIC? |
|---|---|---|
| **Calchas** (GitHub) | 20,391 real HBM2 error events with addresses, plus processed feature tables | **Yes. Chosen.** |
| SmartMem (Kaggle, `kaggle.com/datasets/smartmem/smartmem-features`) | Large DDR4 memory-error feature set from data centers | Bigger, but DDR4 not HBM and needs a separate pipeline. **Dropped** |
| Summit (OLCF) HBM2 GPU data | Public HBM2 failure records from the Summit supercomputer | No correctable errors or addresses, so nothing to predict from |
| Delta, Polaris, Perlmutter GPU resilience studies; Cordial | Papers on GPU and HBM errors in HPC systems | Data not released |
| Alibaba DRAM data | Memory error data from Alibaba's fleet | DRAM, not HBM |
| WM-811K (Kaggle) | 811K wafer maps with defect patterns | About wafer defects, not memory errors in the field |
| PHM 2018 data challenge | Semiconductor ion-mill etch tool sensor data | Tool maintenance, not memory |

Conclusion: Calchas is the only public HBM dataset with correctable errors, addresses and labels. Scale comes from a synthetic fleet simulator built on its patterns.

## Why it matters now

- Meta Llama 3 405B, 54 days on 16,384 H100s: 419 unexpected interruptions, 72 from HBM3 (17.2%), roughly one interruption every 3 hours.
- HBM supply is tight and expected to stay that way through at least 2027, so fleets are run harder and longer (Dr. T's point).

## Sources

- [Calchas paper (USENIX ATC 2024)](https://usenix.org/system/files/atc24-wu-ronglong.pdf)
- [Calchas repository](https://github.com/wrl297/Calchas)
- [Tom's Hardware on Llama 3 training failures](https://www.tomshardware.com/tech-industry/artificial-intelligence/faulty-nvidia-h100-gpus-and-hbm3-memory-caused-half-of-the-failures-during-llama-3-training-one-failure-every-three-hours-for-metas-16384-gpu-training-cluster)
- [Intel Memory Failure Prediction at Meituan](https://www.intel.com/content/dam/www/central-libraries/us/en/documents/2023-12/intel-memory-failure-prediction-improves-reliability-meituan.pdf)
- [SmartMem features on Kaggle](https://www.kaggle.com/datasets/smartmem/smartmem-features)
- [H100 rental prices compared (IntuitionLabs)](https://intuitionlabs.ai/articles/h100-rental-prices-cloud-comparison)
