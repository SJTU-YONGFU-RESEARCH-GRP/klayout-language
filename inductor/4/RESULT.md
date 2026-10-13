# RESULT — inductor/4 — square_4p_xfmr

## Summary

| Field | Value |
|-------|-------|
| Run | `inductor/4` |
| Name | square_4p_xfmr |
| Shape / ports / role | square / **4** / **transformer** |
| Layers | M1 primary + M2 secondary (isolated) |
| Width / space | 1.0 / 1.0 µm |
| Turns / rin | 3.0 / 18.0 µm |
| DRC / LVS / SHORTS | **PASS** / **PASS** / **PASS** |
| EM engine | PEEC_GEOMETRY (primary winding) |
| L₀ (primary) | **0.296 nH** |
| Q @ 2.4 GHz | **1.7** |
| Q_max | **8.4** @ 40 GHz |
| SRF_est | ≈ 184 GHz |

Verdict: First **4-port transformer** in the database — galvanic isolation P↔S verified by SHORTS.

## Layout

![layout](layout/inductor.png)

**Colors:** M1 blue · M2 red · VIA yellow · labels green / magenta

## EM performance

![performance](sim/performance.png)

PEEC currently reports **primary** L/Q/S from the M1 centerline. Secondary (M2) coupling `k` is not extracted yet.

## Diversity

| Run | shape | ports | role |
|-----|-------|------:|------|
| 1 | square | 2 | inductor |
| 2 | figure8 | 2 | inductor |
| 3 | square | 3 | inductor |
| **4** | square | **4** | **transformer** |

## Checks

| Check | Result |
|-------|--------|
| DRC | PASS |
| LVS | PASS (`P1,P2,S1,S2`) |
| SHORTS | PASS (primary ⟂ secondary) |

## Files

- `config.yaml`, `layout/inductor.gds`, `layout/inductor.png`
- `sim/summary.json`, `sim/performance.png`
