# Calchas HBM error dataset: notes

- Repo: https://github.com/wrl297/Calchas (linked here as the `Calchas/` submodule, commit 9d3955c)
- Data: copied exactly from that commit into `calchas-data/`, so it's here even without the submodule
- Paper: Wu et al., "Removing Obstacles before Breaking Through the Memory Wall: A Close Look at HBM Errors in the Field," USENIX ATC 2024. https://usenix.org/system/files/atc24-wu-ronglong.pdf
- License: none stated. Cite the paper; coursework use only.
- Decision: this is the **only** real dataset for PANIC. SmartMem (DDR4) was dropped. Scale comes from a synthetic fleet simulator tuned to these patterns.

## Raw log: `calchas-data/raw_data/dataset(opensource).csv`

- 20,391 error events, April 2022 to February 2024, 8 data centers, 50 servers (HBM2 on AI accelerators).
- Columns: `Datacenter, Server, Name, Stack, SID, PcId, BankGroup, BankArray, Col, Row, Time, EccType`
  - Stack / SID / PcId / BankGroup / BankArray / Row / Col = where in the HBM the error happened (stack, stack ID, pseudo-channel, bank group, bank, row, column).
  - `EccType`:
    - **CE** (correctable error): 10,470. ECC fixed it. The early warning signal.
    - **UEO** (uncorrectable error, action optional): 9,587.
    - **UER** (uncorrectable error, action required): 334. The thing we want to predict.
- Has timestamps and server IDs, so it supports an honest time-based train/test split and the hourly replay.

## Processed tables: `calchas-data/processed_data/`

Ready-made features and labels from the paper.

| File | Rows | Positives | Rate | Windows |
|---|---|---|---|---|
| `data_for_row-level_prediction.csv` | 62,930 | 193 | 0.31% | 1-day observation, 1-hour prediction |
| `data_for_col-level_prediction.csv` | 62,930 | 248 | 0.39% | 1-day observation, 1-hour prediction |
| `data_for_bank-level_prediction.csv` | 62,930 | 427 | 0.68% | 1-day observation, 1-hour prediction |
| `data_for_server-level_prediction.csv` | 105,826 | 543 | 0.51% | 30-day observation, 1-day prediction |

- The last column is the label (for example `label_row_p1h_l0`).
- Includes temperature and power features that the raw log doesn't have.
- **Catch:** no timestamps or server IDs, so you can only do a random split on these. Fine for a quick baseline, not for the final evaluation.
- Very imbalanced (0.3% to 0.7% positive): use class weights, threshold tuning, and report precision and recall, not accuracy.

## Benchmarks to beat (paper F1)

Row 0.78 · Column 0.79 · Bank 0.70 · Server 0.42. Paper averages: precision 58.0%, recall 74.6%.

## Quick baseline: `baseline.py`

Random forest (200 trees, balanced class weights), random 70/30 stratified split, threshold 0.5, untuned. Needs `pip install pandas scikit-learn`. Run:

```
python baseline.py "calchas-data/processed_data"
```

Result (Oct 30): row-level F1 about 0.69. Prints rows, positives, precision, recall and F1 for each level.

## How it scales (for the design doc)

- The full Calchas collection behind the paper is about 460M events (about 630K per day); only this sample is public.
- The scale test in the Gantt chart targets 630K errors per day through Kinesis.
- Fleet sizes: H100 = 5 HBM3 stacks, B200 = 8. Meta's 16,384-GPU cluster ≈ 82K stacks. xAI Colossus 1 ≈ 1.3M stacks.
