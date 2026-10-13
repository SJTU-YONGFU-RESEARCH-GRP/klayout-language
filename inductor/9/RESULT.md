# RESULT — inductor/9 — circle_3p_ct_l2

## Summary

| Field | Value |
|-------|-------|
| Run | `inductor/9` |
| Name | circle_3p_ct_l2 |
| Shape / ports / role | **circle** / **3** / inductor |
| Layers | M1 spiral + M2 underpass + M2 CT stub |
| Width / space | 1.0 / 1.0 µm |
| Turns / rin | 3.0 / 16.0 µm |
| DRC / LVS / SHORTS | **PASS** / **PASS** / **PASS** |
| EM engine | PEEC_GEOMETRY |
| L₀ | **0.090 nH** |
| Q @ 2.4 GHz | **0.4** |
| Q_max | **2.0** @ 40 GHz |
| SRF_est | ≈ 293 GHz |

Verdict: Shape rotated **square → circle** (picker). First **circle center-tap**.

## Layout

![layout](layout/inductor.png)

**Colors:** M1 blue · M2 red · VIA yellow · labels green / magenta

## EM performance

![performance](sim/performance.png)

| Metric | Value |
|--------|-------|
| Segments / length | 216 / 382 µm |
| Engine | PEEC_GEOMETRY |
| Data | `sim/lq.csv`, `sim/sparams.csv`, `sim/summary.json` |

## Diversity

| Run | shape | ports | role |
|-----|-------|------:|------|
| 8 | square | 4 | coupler |
| **9** | **circle** | **3** | inductor |

## Checks

| Check | Result |
|-------|--------|
| DRC | PASS |
| LVS | PASS (`P1,P2,CT`) |
| SHORTS | PASS (3 vias) |

## Files

- `config.yaml` (from `pick_next_config.py`), `layout/inductor.gds`, `layout/inductor.png`
- `sim/summary.json`, `sim/performance.png`
