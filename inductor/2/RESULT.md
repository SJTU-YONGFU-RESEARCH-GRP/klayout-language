# RESULT — inductor/2 — figure8_2p_l1

## Summary

| Field | Value |
|-------|-------|
| Run | `inductor/2` |
| Name | figure8_2p_l1 |
| Shape | **figure8** (new vs DB: run 1 was `square`) |
| Ports / role | 2 / inductor |
| Layers | 1 (M1) |
| Width / space | 1.0 µm / 1.0 µm |
| Turns | 2.5 per loop |
| Inner radius | 12.0 µm |
| DRC | **PASS** (0 violations) |
| LVS | **PASS** (P1↔P2 connectivity) |
| openEMS | **SKIPPED** (analytic placeholder) |

Verdict: Distinct **figure-8** topology vs run 1’s square spiral (not a turn tweak). Layout verified; EM is analytic until openEMS is installed.

## Layout screenshot

![IND_F8_2P figure-8 2-port inductor](layout/inductor.png)

**Layer colors:** M1 **blue** · M2 **red** · VIA **yellow** · M1 labels **green** · M2 labels **magenta**

## Diversity vs existing database

| Run | shape | ports | role |
|-----|-------|-------|------|
| 1 | square | 2 | inductor |
| **2** | **figure8** | 2 | inductor |

## Config

```yaml
name: figure8_2p_l1
cell: IND_F8_2P
shape: figure8
ports: 2
role: inductor
n_layers: 1
width_um: 1.0
space_um: 1.0
turns: 2.5
inner_radius_um: 12.0
```

## DRC

- Command: `./inductor/common/run_drc.sh inductor/2`
- Violations: 0
- Log: `drc/inductor.log`

## LVS

- Command: `./inductor/common/run_lvs.sh inductor/2`
- Result: PASS — labels `P1,P2` DC-connected
- Log: `lvs/inductor.log`

## EM (openEMS)

| Metric | Value | Note |
|--------|-------|------|
| L (est.) | ≈ 0.292 nH | analytic |
| Q placeholder | ≈ 12.7 @ 20 GHz | not physical EM |
| f_ref | 2.4 GHz | config |

- Data: `sim/sparams.csv`, `sim/lq.csv`
- Status: `sim/STATUS.txt` → `SKIPPED_OPENEMS`

## Files

- `config.yaml`
- `layout/inductor.gds` (cell `IND_F8_2P`)
- `layout/inductor.png`

## Next steps

- Install openEMS for real Q / S-params
- Next unused shapes/roles: `octagon`, `circle`, or 3-port / 4-port transformer
