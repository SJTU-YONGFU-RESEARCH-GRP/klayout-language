# RESULT — inductor/1 — square_2p_l1

## Summary

| Field | Value |
|-------|-------|
| Run | `inductor/1` |
| Name | square_2p_l1 |
| Shape | square |
| Ports / role | 2 / inductor |
| Layers | 1 (M1) |
| Width / space | 1.0 µm / 1.0 µm |
| Turns | 3.5 |
| Inner radius | 20.0 µm |
| DRC | **PASS** (0 violations) |
| LVS | **PASS** (P1↔P2 connectivity) |
| openEMS | **SKIPPED** (module not installed; analytic placeholder) |

Verdict: Layout generated and verified; EM metrics are analytic estimates until openEMS is available.

## Layout screenshot

![IND_SQ_2P square 2-port inductor](layout/inductor.png)

**Layer colors:** M1 **blue** · M2 **red** · VIA **yellow** · M1 labels **green** · M2 labels **magenta**

(This run is 1-layer, so only M1 + green `P1`/`P2` labels appear.)

## Config

```yaml
name: square_2p_l1
cell: IND_SQ_2P
shape: square
ports: 2
role: inductor
n_layers: 1
width_um: 1.0
space_um: 1.0
turns: 3.5
inner_radius_um: 20.0
```

## DRC

- Command: `./inductor/common/run_drc.sh inductor/1`
- Violations: 0
- Log: `drc/inductor.log`
- Report: `drc/inductor.lyrdb`

## LVS

- Command: `./inductor/common/run_lvs.sh inductor/1`
- Result: PASS — labels `P1,P2` DC-connected on M1
- Schematic (documentary): `lvs/inductor.cir`
- Log: `lvs/inductor.log`

## EM (openEMS)

openEMS/CSXCAD not installed on this host. Pipeline wrote Greenhouse-like analytic placeholders:

| Metric | Value | Note |
|--------|-------|------|
| L (est.) | ≈ 0.901 nH | analytic |
| Q @ high-f placeholder | ≈ 39 @ 20 GHz | not physical EM |
| f_ref | 2.4 GHz | config |

- Data: `sim/sparams.csv`, `sim/lq.csv`
- Status: `sim/STATUS.txt` → `SKIPPED_OPENEMS`

## Files

- `config.yaml`
- `layout/inductor.gds` (cell `IND_SQ_2P`)
- `layout/inductor.png` (screenshot)

## Next steps

- Install openEMS + CSXCAD Python bindings, then re-run `./inductor/common/run_openems.sh inductor/1`
- Try `shape: octagon` or `ports: 4` / `role: transformer` in a new `inductor/2` run via **create-inductor**
