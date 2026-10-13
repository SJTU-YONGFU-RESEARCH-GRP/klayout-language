# create-inductor — reference

## Shapes

| `shape` | Geometry | Notes |
|---------|----------|-------|
| `square` | Orthogonal spiral | Simplest polygons |
| `octagon` | 45° octagonal spiral | Default; good Q vs area |
| `circle` | Approximated N-gon spiral | Highest Q potential |
| `figure8` | Two loops, opposing field | Lower substrate coupling |

When adding a run, scan `inductor/*/config.yaml` and choose an unused `(shape, ports, role)` — never only change `turns`.

## Avoiding parallel short paths

Inductance requires **one series path**. A turn-to-turn metal bridge (or via pad touching two turns) creates a DC bypass that shorts out loops.

### Cut-test (`check_shorts.rb`)

1. Rebuild the design centerline from config.
2. At ~35% / 50% / 65% along the path, cut a notch across the M1 trace.
3. After each cut, **P1 and P2 must disconnect** on M1.
4. If they stay connected → a parallel short exists → `SHORTS FAIL`.

Also enforced:

- ≤1 M1 polygon for 2p/3p (no via-pad islands)
- Via count caps: 2p→0 (or 2 only for real underpass), 3p→1 (CT only), 4p→0
- 4p: primary must not DC-connect to secondary

### Generator rules of thumb

- Never add “decorative” M2/via under a 2-port spiral.
- CT via only on the outer lead, stub pointing **away** from the spiral.
- Stacked transformer: no vias between windings.

## Ports and roles

### 2-port (`ports: 2`, `role: inductor`)

Single winding. Labels: `P1`, `P2`. Uses M1; optional M2 underpass for crossover.

### 3-port (`ports: 3`, `role: inductor`)

Center-tapped spiral. Labels: `P1`, `P2`, `CT`. CT usually at geometric mid-turn via M2 bridge.

### 4-port transformer (`ports: 4`, `role: transformer`)

Stacked or interleaved primary/secondary. Labels: `P1`, `P2` (primary), `S1`, `S2` (secondary).

### 4-port coupler (`ports: 4`, `role: coupler`)

Coupled lines / loosely coupled spirals. Same label set as transformer; lower k target.

### Balun (`ports: 4` or `3`, `role: balun`)

Often center-tapped secondary (3-port secondary view) or 4-port SE–DIFF. Document pin map in `config.yaml` `pin_map`.

## Layer stack (demo process)

Not a foundry PDK — educational stack for this repo:

| GDS | Name | Role |
|-----|------|------|
| 31/0 | M1 | Bottom / primary metal |
| 32/0 | M2 | Top / secondary / underpass |
| 30/0 | VIA | M1–M2 |
| 31/1 | M1 TEXT | Port labels |
| 32/1 | M2 TEXT | Port labels |

| Layer | Thickness (sim) | Conductivity |
|-------|-----------------|--------------|
| M1 | 0.5 µm | copper-like 5.8e7 S/m |
| VIA | 0.5 µm height | same |
| M2 | 0.5 µm | same |
| Substrate | below | lossy Si or optional PGS |

Override in `config.yaml` → `em:` block.

LVS uses `check_connectivity.rb` (DC port topology), not MOS-style device compare.

## DRC intent

Default min width/space = **1.0 µm** on M1 and M2 (matches generator).  
Enclosure: metal over via ≥ 0.2 µm (configurable).

## LVS intent

Schematic is a pin-accurate subcircuit:

```spice
.SUBCKT IND_2P P1 P2
L1 P1 P2 {L_est}
.ENDS
```

For 4-port:

```spice
.SUBCKT XFMR_4P P1 P2 S1 S2
L1 P1 P2 {Lp}
L2 S1 S2 {Ls}
K12 L1 L2 {k}
.ENDS
```

LVS checks port connectivity / shorts / opens; L/k values are estimates for documentation, not extracted EM truth.

## openEMS

Dependencies: `openEMS`, `CSXCAD`, Python bindings (`from openEMS import openEMS`).

Install (from repo root; wraps official [openEMS-Project](https://github.com/thliebig/openEMS-Project) build):

```bash
./scripts/install-openems.sh --deps --disable-gui   # first time (sudo for OS packages)
# or update an existing install:
./scripts/install-openems.sh --update

source ~/.local/bin/openems-env
python3 -c "from openEMS import openEMS; print('ok')"
```

Default prefix: `~/opt/openEMS` (venv at `~/opt/openEMS/venv`). See `./scripts/install-openems.sh --help`.

Sim defaults:

- Unit: 1e-6 (µm)
- Freq sweep: 0.1–20 GHz (adjust in config `em.f_start_hz` / `em.f_stop_hz`)
- Mesh: metal ≤ width/4
- Boundary: PML / MUR

Outputs:

- `sim/sparams.csv` — frequency, Sij mag/phase or real/imag
- `sim/lq.csv` — f, L_H, Q, R_series
- optional `sim/*.png` plots

Q extraction (2-port series):  
`Z = Z0 * (1+S11)/(1-S11)` (one-port remapped) or from Y/Z two-port;  
`L = Im(Z)/ω`, `Q = Im(Z)/Re(Z)`.

## Run folder layout

```
inductor/<N>/
  config.yaml
  layout/inductor.gds
  drc/*.log *.lyrdb
  lvs/*.cir *.lvsdb *.log
  sim/sparams.csv lq.csv …
  RESULT.md
```
