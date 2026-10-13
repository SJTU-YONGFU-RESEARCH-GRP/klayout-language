# RESULT — inductor/7 — octagon_3p_ct_l2

## Summary

| Field | Value |
|-------|-------|
| Run | `inductor/7` |
| Name | octagon_3p_ct_l2 |
| Shape / ports / role | **octagon** / **3** / inductor |
| Layers | M1 spiral + M2 underpass + M2 CT stub |
| Width / space | 1.0 / 1.0 µm |
| Turns / rin | 3.0 / 16.0 µm |
| DRC / LVS / SHORTS | **PASS** / **PASS** / **PASS** |
| EM engine | PEEC_GEOMETRY |
| L₀ | **0.318 nH** |
| Q @ 2.4 GHz | **1.1** |
| Q_max | **5.4** @ 40 GHz |
| SRF_est | ≈ 141 GHz |

Verdict: First **octagon center-tap** (3-port) — CT clear of deepened underpass channel.

## Layout

![layout](layout/inductor.png)

**Colors:** M1 blue · M2 red · VIA yellow · labels green / magenta

## EM performance

![performance](sim/performance.png)

| Metric | Value |
|--------|-------|
| Segments / length | 25 / 465 µm |
| Engine | PEEC_GEOMETRY (Grover L + skin R + oxide C) |
| Data | `sim/lq.csv`, `sim/sparams.csv`, `sim/summary.json` |

## Diversity

| Run | shape | ports | role |
|-----|-------|------:|------|
| 1 | square | 2 | inductor |
| 2 | figure8 | 2 | inductor |
| 3 | square | 3 | inductor |
| 4 | square | 4 | transformer |
| 5 | circle | 2 | inductor |
| 6 | octagon | 2 | inductor |
| **7** | **octagon** | **3** | inductor |

## Checks

| Check | Result |
|-------|--------|
| DRC | PASS |
| LVS | PASS (`P1,P2,CT`) |
| SHORTS | PASS (3 vias: 2 underpass + 1 CT) |

## Files

- `config.yaml`, `layout/inductor.gds`, `layout/inductor.png`
- `sim/summary.json`, `sim/performance.png`
