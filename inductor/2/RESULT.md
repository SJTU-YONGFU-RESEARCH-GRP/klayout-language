# RESULT — inductor/2 — figure8_2p_l1

## Summary

| Field | Value |
|-------|-------|
| Run | `inductor/2` |
| Shape / ports | figure8 / 2 |
| DRC / LVS / SHORTS | **PASS** / **PASS** / **PASS** |
| EM engine | **PEEC_GEOMETRY** |
| L₀ | **0.271 nH** |
| Q @ 2.4 GHz | **1.3** |
| Q_max | **6.5** @ 40 GHz |
| SRF_est | ≈ 177 GHz |

## Layout

![layout](layout/inductor.png)

## EM performance

![performance](sim/performance.png)

| Metric | Value |
|--------|-------|
| Segments / length | 22 / 344 µm |
| Data | `sim/lq.csv`, `sim/sparams.csv`, `sim/summary.json` |
