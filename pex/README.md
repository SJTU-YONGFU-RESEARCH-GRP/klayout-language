# M1 Resistor PEX Demo (KLayout)

Minimal **parasitic R extraction** with the built-in `RNetExtractor` (square counting) — same GOOD pass / BAD fail pattern as [`../drc/`](../drc/) and [`../lvs/`](../lvs/).

![R_DEMO — GOOD (top) vs BAD (bottom)](../screenshots/pex_r_demo.png)

| Cell | Layout | Squares | Expected R (@ 0.08 Ω/□) | Result |
|------|--------|---------|-------------------------|--------|
| `R_GOOD` | L=2.0 µm, W=1.0 µm | 2 | **0.16 Ω** | **PASS** (R < 1.0) |
| `R_BAD` | L=16.0 µm, W=0.20 µm | 80 | **6.40 Ω** | **FAIL** (R ≥ 1.0) |
| `R_DEMO` | Both (for viewing) | — | — | — |

Sheet resistance is an educational constant (`0.08` ohm/square), not a foundry deck.

Sibling demos: [`../drc/`](../drc/) · [`../lvs/`](../lvs/).

---

## Quick start

```bash
cd pex
./run_pex.sh              # GOOD → PASS, BAD → FAIL
./run_pex.sh --good
./run_pex.sh --bad

./view_pex.sh             # GUI + print last report
./view_pex.sh --bad
./view_pex.sh --demo

./run_clean.sh
```

Requires [KLayout](https://www.klayout.de/) **0.30.2+** on `PATH` (`../scripts/install-klayout.sh`) — needs the built-in `pex` / `RNetExtractor` API.

```bash
klayout -b \
  -rd input=r_demo.gds \
  -rd cell=R_GOOD \
  -rd report=r_good.txt \
  -rd spice=r_good_extracted.cir \
  -rd sheet_r=0.08 \
  -rd r_limit=1.0 \
  -r extract_r.rb
```

---

## Files

| File | Role |
|------|------|
| `generate_layout.rb` | Builds `r_demo.gds` (GOOD + BAD + DEMO) |
| `r_demo.gds` | Test layout |
| `extract_r.rb` | `RNetExtractor` + PASS/FAIL vs `r_limit` |
| `run_pex.sh` | Generate + run GOOD/BAD |
| `view_pex.sh` | Open GDS + show report |
| `run_clean.sh` | Delete reports / spice (`--gds` removes GDS) |

Generated (gitignored): `r_{good,bad}.{txt,log}`, `r_*_extracted.cir`

---

## Layers

| GDS | Name | Screenshot color | Role |
|-----|------|------------------|------|
| 31/0 | M1 | blue | resistor + pads |
| 90/0 | labels | purple | A / B / titles |
| 100/0 | marker | magenta | BAD highlight (screenshots) |
| 101/0 | dim | black | rulers (screenshots) |
| 102/0 | dimtxt | purple | dimension text |

---

## How `extract_r.rb` works

### Tech stack

```ruby
tech = RExtractorTech.new
cond = RExtractorTechConductor.new
cond.layer = 31
cond.resistance = 0.08          # ohm / square
cond.algorithm = RExtractorTechConductor::SquareCounting
tech.add_conductor(cond)
```

### Geometry + ports

Pads stay separate boxes in GDS; the extractor merges the M1 net, then uses the **leftmost / rightmost** polygons as polygon ports A and B:

```ruby
geo = { 31 => merged_region }
polygon_ports = { 31 => [pad_a, pad_b] }
network = RNetExtractor.new(dbu).extract(tech, geo, {}, polygon_ports)
network.simplify
```

Expected: `R ≈ (L / W) × sheet_r`.

### PASS / FAIL

```ruby
ok = r_total < r_limit   # default limit = 1.0 ohm
puts ok ? "PEX PASS — ..." : "PEX FAIL — ..."
```

Also writes a tiny SPICE subcircuit:

```spice
.SUBCKT R_GOOD A B
R1 A B 0.16
.ENDS
```

---

## Good vs bad

| GOOD (`R_GOOD`) | BAD (`R_BAD`) |
|:---------------:|:-------------:|
| ![GOOD](../screenshots/pex_r_good.png) | ![BAD](../screenshots/pex_r_bad.png) |
| Wide short wire → 0.16 Ω | Skinny long wire → 6.40 Ω |

| GOOD zoom + L/W rulers | BAD zoom + R highlight |
|:----------------------:|:----------------------:|
| ![GOOD zoom](../screenshots/pex_case_good_lw.png) | ![BAD zoom](../screenshots/pex_case_bad_r.png) |

---

## Screenshots

```bash
../scripts/run_capture_screenshots.sh
```

| File | Content |
|------|---------|
| [`../screenshots/pex_r_demo.png`](../screenshots/pex_r_demo.png) | GOOD + BAD |
| [`../screenshots/pex_r_good.png`](../screenshots/pex_r_good.png) | Low-R resistor |
| [`../screenshots/pex_r_bad.png`](../screenshots/pex_r_bad.png) | High-R resistor |
| [`../screenshots/pex_case_good_lw.png`](../screenshots/pex_case_good_lw.png) | Zoom L/W rulers |
| [`../screenshots/pex_case_bad_r.png`](../screenshots/pex_case_bad_r.png) | Zoom + high-R mark |

---

## See also

- [`../docs/PEX.md`](../docs/PEX.md) — built-in `RExtractor` / `RNetExtractor` reference  
- [`../drc/`](../drc/) — M1 / Contact DRC  
- [`../lvs/`](../lvs/) — NMOS LVS  
- [KLayout-PEX (`kpex`)](https://iic-jku.github.io/klayout-pex-website/doc/doc.html) — separate full-flow tool (not used here)
