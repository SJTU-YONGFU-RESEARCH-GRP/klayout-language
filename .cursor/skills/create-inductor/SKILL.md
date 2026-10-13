---
name: create-inductor
description: >-
  Designs 1–2 metal-layer on-chip CMOS inductors (spiral, octagon, circle,
  figure-8; 2/3/4-port including center-tap, transformer, coupler) under
  inductor/, with KLayout DRC/LVS and openEMS Q/S-parameter analysis writing
  RESULT.md per run. Use when creating inductors, transformers, baluns,
  couplers, or when the user mentions create-inductor, inductor/N, openEMS
  inductor sim, or on-chip spiral design.
disable-model-invocation: true
---

# create-inductor

Generate and verify on-chip inductors under `inductor/` in **klayout-language**.
Each design run lives in `inductor/<N>/` and ends with `RESULT.md`.

## Defaults (override only if user asks)

| Param | Default |
|-------|---------|
| Metal layers | 1 or 2 (`n_layers`) |
| Trace width | **1.0 µm** |
| Trace space | **1.0 µm** |
| Shapes | square / octagon / circle / figure8 |
| Ports | 2 (series), 3 (center-tap), 4 (transformer / coupler) |
| Work root | `inductor/` |
| Run folder | `inductor/<N>/` (next free integer) |

## When invoked

Copy this checklist and track it:

```
create-inductor Progress:
- [ ] 1. Allocate run folder inductor/<N>
- [ ] 2. Write config.yaml (diversify + no multi-path shorts)
- [ ] 3. Generate GDS (+ port labels)
- [ ] 4. Run DRC → record pass/fail
- [ ] 5. Run LVS + SHORTS cut-test → record pass/fail
- [ ] 6. Screenshot → layout/inductor.png (blue/red/yellow/…)
- [ ] 7. openEMS sim → S-params, L, Q
- [ ] 8. Write RESULT.md (must embed screenshot)
```

### Step 1 — Allocate run folder

```bash
cd inductor
N=$(ls -d [0-9]* 2>/dev/null | sort -n | tail -1)
N=$(( ${N:-0} + 1 ))
mkdir -p "$N"/{layout,drc,lvs,sim}
```

If the user names a folder (e.g. `inductor/1`), use that and overwrite only with confirmation.

### Step 2 — Write `config.yaml` (must diversify)

Use [templates/config.yaml](../../../inductor/common/templates/config.yaml) as the schema.
Required keys: `name`, `shape`, `ports`, `n_layers`, `width_um`, `space_um`, `turns`, `inner_radius_um`, `role`.

`role` ∈ `inductor` | `transformer` | `coupler` | `balun`

**Diversity rule (mandatory for every new run):**

1. Read all existing `inductor/*/config.yaml` (skip `common/`).
2. Collect used `(shape, ports, role)` combinations.
3. Pick a config that is **not** a turn/radius tweak of an existing entry.
4. At least one of `shape`, `ports`, or `role` must be new to the database.
5. Prefer unused `shape` first (`square` → `octagon` → `circle` → `figure8`), then new port/role (3-port CT, 4-port transformer/coupler).

❌ Forbidden: same `shape` + same `ports` + same `role`, only changing `turns` / `inner_radius_um`.  
✅ Examples: square 2p exists → use `figure8` 2p, or `octagon` 3p, or `square` 4p transformer.

Port mapping:

| ports | Topology |
|-------|----------|
| 2 | Single spiral, Port1–Port2 |
| 3 | Center-tapped spiral (P1–CT–P2) |
| 4 | Two windings (transformer/coupler/balun) |

Shape/port details: [reference.md](reference.md).

### Step 3 — Generate layout

From repo root or `inductor/`:

```bash
python3 inductor/common/generate_inductor.py \
  --config inductor/<N>/config.yaml \
  --out inductor/<N>/layout/inductor.gds
```

Layers (fixed for this flow):

| GDS | Name | Role |
|-----|------|------|
| 31/0 | M1 | Bottom spiral / primary |
| 32/0 | M2 | Top spiral / secondary / underpass |
| 30/0 | VIA | M1–M2 vias |
| 31/1 | M1 TEXT | Port labels on M1 (`P1`, `P2`, …) |
| 32/1 | M2 TEXT | Port labels on M2 (`CT`, `S1`, `S2`, …) |

Generator must honor `width_um` / `space_um` exactly (default 1.0 / 1.0).

### Single-series-path rule (avoid multiple short-circuit paths)

An inductor winding must be **one series ribbon** from port to port. Extra DC bridges between turns kill inductance.

| Rule | Required |
|------|----------|
| One M1 series path | 2-port / 3-port: a single continuous M1 path; no turn-to-turn metal bridges |
| No decorative vias | Do **not** drop via+M1 pads that touch adjacent turns |
| Underpass only if needed | M2 underpass only at an intentional crossover with **exactly** the vias required (usually 2); never a via forest |
| Center-tap | Exactly **one** CT via on an **outer lead**, clear of the spiral body; M2 stub must not re-enter the turns |
| Transformer (4-port) | **Zero** vias between primary (M1) and secondary (M2) — galvanic isolation |
| Verify | `./inductor/common/run_shorts.sh inductor/<N>` (cut-test: after cutting mid-trace, P1–P2 must open) |

❌ Forbidden: floating via pads, M2 stubs that cross the spiral with extra vias, overlapping paths, turn shorts.  
✅ Pass criterion: `SHORTS PASS` in `lvs/shorts.log`.

Details: [reference.md](reference.md#avoiding-parallel-short-paths).

### Step 4 — DRC

```bash
./inductor/common/run_drc.sh inductor/<N>
```

Rules (see `inductor/common/inductor.drc`): M1/M2 min width & space = config values (default 1.0 µm); VIA min width/space; M over VIA enclosure. Expect **PASS** for generator output.

Save log under `inductor/<N>/drc/`.

### Step 5 — LVS + short-path check

```bash
./inductor/common/run_lvs.sh inductor/<N>    # includes run_shorts.sh
# or separately:
./inductor/common/run_shorts.sh inductor/<N>
```

- Write documentary SPICE (`lvs/inductor.cir`) via `write_schematic.py`.
- `check_connectivity.rb`: port labels match topology (2p: P1↔P2; 3p: P1–CT–P2; 4p: windings isolated).
- `check_shorts.rb`: **cut-test** for parallel/bypass shorts + via-count limits.
- Save `lvs/inductor.log` and `lvs/shorts.log`. Both must PASS.

### Step 6 — Screenshot

```bash
./inductor/common/run_screenshot.sh inductor/<N>
```

Writes `layout/inductor.png` with fixed high-contrast colors:

| Layer | Color |
|-------|-------|
| M1 (31/0) | blue |
| M2 (32/0) | red |
| VIA (30/0) | yellow |
| M1 labels (31/1) | green |
| M2 labels (32/1) | magenta |

### Step 7 — openEMS

```bash
./inductor/common/run_openems.sh inductor/<N>
```

Pipeline (`inductor/common/openems/`):

1. Export metal polygons → CSXCAD geometry (µm → m).
2. FDTD ports at labeled pads; broadband pulse.
3. Record S-parameters → `sim/sparams.csv`.
4. Extract series L and Q vs frequency → `sim/lq.csv`.

If openEMS / CSXCAD missing, install notes are in [reference.md](reference.md#openems). Still write `RESULT.md` with DRC/LVS and mark EM as **SKIPPED** + reason.

### Step 8 — Write `RESULT.md`

Mandatory path: `inductor/<N>/RESULT.md`  
Template: [result-template.md](result-template.md)

Must include: **layout screenshot** (`![…](layout/inductor.png)`), config summary, DRC/LVS status, EM metrics (L, Q_max, f @ Q_max, key S-params), next-step notes.

## Agent rules

- All work products stay under `inductor/` (shared code in `inductor/common/`, runs in `inductor/<N>/`).
- Do not invent DRC/LVS/SHORTS PASS without running the scripts (or recording SKIPPED).
- Prefer regenerating GDS from `config.yaml` over hand-editing polygons.
- If SHORTS FAIL: fix generator/config (remove vias/bridges); do not weaken the cut-test.
- Match sibling demo style in `drc/` and `lvs/` (shell runners, KLayout `-b`).
- After a successful run, briefly tell the user: path to `RESULT.md`, PASS/FAIL, SHORTS, and peak Q / L if EM ran.

## Quick commands

```bash
# First / next run (example: use folder 1)
python3 inductor/common/generate_inductor.py \
  --config inductor/1/config.yaml --out inductor/1/layout/inductor.gds
./inductor/common/run_drc.sh inductor/1
./inductor/common/run_lvs.sh inductor/1
./inductor/common/run_screenshot.sh inductor/1
./inductor/common/run_openems.sh inductor/1
# then write inductor/1/RESULT.md (embed layout/inductor.png)
```
