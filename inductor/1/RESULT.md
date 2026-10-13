# RESULT — inductor/1 — square_2p_l1

## Summary

| Field | Value |
|-------|-------|
| Run | `inductor/1` |
| Shape / ports | square / 2 |
| DRC / LVS / SHORTS | **PASS** / **PASS** / **PASS** |
| EM engine | **PEEC_GEOMETRY** (GDS centerline → Grover L + skin R + oxide C) |
| L₀ | **0.456 nH** |
| L @ 2.4 GHz | **0.456 nH** |
| Q @ 2.4 GHz | **2.0** |
| Q_max | **9.4** @ 40 GHz |
| SRF_est | ≈ 130 GHz |

## Layout

![layout](layout/inductor.png)

## EM performance

![performance](sim/performance.png)

| Metric | Value |
|--------|-------|
| Segments / length | 15 / 379 µm |
| C_ox | ≈ 3.3 fF |
| Metal thickness | 3.0 µm (config `em`) |
| Data | `sim/lq.csv`, `sim/sparams.csv`, `sim/summary.json` |

> openEMS FDTD is not installed on this host (full build needed). Pipeline used **physical PEEC from the real GDS ribbon**. Install openEMS later for full-wave S-params.

## Checks

- DRC / LVS / SHORTS: PASS  
- Command: `./inductor/common/run_openems.sh inductor/1`
