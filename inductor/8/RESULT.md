# RESULT — inductor/8 — square_4p_coup_l2

## Summary

| Field | Value |
|-------|-------|
| Run | `inductor/8` |
| Name | square_4p_coup_l2 |
| Shape / ports / role | **square** / **4** / **coupler** |
| Layers | M1 primary + M2 secondary (isolated) |
| Width / space | 1.0 / 1.0 µm |
| Turns / rin | 3.0 / 18.0 µm |
| DRC / LVS / SHORTS | **PASS** / **PASS** / **PASS** |
| EM engine | PEEC_GEOMETRY (primary) |
| L₀ (primary) | **0.296 nH** |
| Q @ 2.4 GHz | **1.7** |
| Q_max | **8.4** @ 40 GHz |
| SRF_est | ≈ 184 GHz |

Verdict: Shape rotated **octagon → square** (picker). First **coupler** role — same stacked geometry as transformer, isolated P↔S.

## Layout

![layout](layout/inductor.png)

**Colors:** M1 blue · M2 red · VIA yellow · labels green / magenta

## EM performance

![performance](sim/performance.png)

PEEC reports **primary** L/Q from the M1 centerline. Coupling `k` not extracted yet.

## Diversity

| Run | shape | ports | role |
|-----|-------|------:|------|
| 7 | octagon | 3 | inductor |
| **8** | **square** | **4** | **coupler** |

## Checks

| Check | Result |
|-------|--------|
| DRC | PASS |
| LVS | PASS (`P1,P2,S1,S2`) |
| SHORTS | PASS (primary ⟂ secondary) |

## Files

- `config.yaml` (from `pick_next_config.py`), `layout/inductor.gds`, `layout/inductor.png`
- `sim/summary.json`, `sim/performance.png`
