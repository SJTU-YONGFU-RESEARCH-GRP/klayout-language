# On-chip inductor design flow

Work directory for **create-inductor** runs. Shared tooling lives in `common/`; each design is `inductor/<N>/`.

## Defaults

- 1–2 metal layers (M1 / M2)
- Trace **width = 1.0 µm**, **space = 1.0 µm**
- Shapes: `square` | `octagon` | `circle` | `figure8`
- Ports: 2 / 3 (center-tap) / 4 (transformer, coupler, balun)
- Verify: KLayout **DRC** + connectivity **LVS**
- EM: **openEMS** (or analytic placeholder) → Q, S-params
- Per-run report: `RESULT.md`

## Quick start (run 1)

```bash
cd /path/to/klayout-language

python3 inductor/common/generate_inductor.py \
  --config inductor/1/config.yaml \
  --out inductor/1/layout/inductor.gds

./inductor/common/run_drc.sh inductor/1
./inductor/common/run_lvs.sh inductor/1
./inductor/common/run_openems.sh inductor/1
```

Then inspect `inductor/1/RESULT.md`.

## New run

```bash
N=$(( $(ls -d inductor/[0-9]* 2>/dev/null | sort -n | tail -1 | xargs -n1 basename) + 1 ))
mkdir -p inductor/$N/{layout,drc,lvs,sim}
cp inductor/common/templates/config.yaml inductor/$N/config.yaml
# edit config, then generate + DRC + LVS + openEMS + RESULT.md
```

Or invoke the Cursor skill **create-inductor**.

## Layers

| GDS | Name |
|-----|------|
| 31/0 | M1 |
| 32/0 | M2 |
| 30/0 | VIA |
| 31/1 | M1 TEXT (P1, P2, …) |
| 32/1 | M2 TEXT (CT, S1, S2, …) |

## Skill

Project skill: [`.cursor/skills/create-inductor/`](../.cursor/skills/create-inductor/)
