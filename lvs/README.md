# NMOS Transistor LVS Demo (KLayout + Calibre)

Side-by-side **KLayout** and optional **Calibre** LVS on the same NMOS layout — GOOD pass / BAD fail (S–D short). Same pattern as [`../drc/`](../drc/) and [`../pex/`](../pex/).

![NMOS_DEMO — GOOD (left) vs BAD S–D short (right)](../screenshots/lvs_nmos_demo.png)

| Cell | Layout | Expected |
|------|--------|----------|
| `NMOS_GOOD` | Correct S / G / D / B | **PASS** |
| `NMOS_BAD` | Metal shorts S–D | **FAIL** |
| `NMOS_DEMO` | Both (for viewing) | — |

Device: **L = 0.18 µm**, **W = 0.50 µm** (matches `nmos.cir`).

Sibling demos: [`../drc/`](../drc/) (M1 / Contact DRC) · [`../pex/`](../pex/) (M1 R extraction).

---

## Quick start

```bash
cd lvs
./run_lvs.sh              # KLayout: GOOD → PASS, BAD → FAIL
./run_lvs.sh --good       # GOOD only
./run_lvs.sh --bad        # BAD only (expect FAIL)

./view_lvs.sh             # GUI + GOOD LVS DB
./view_lvs.sh --bad

# optional Calibre (needs calibre.env — see below)
./run_calibre_lvs.sh
./view_calibre_lvs.sh             # summary (+ RVE if calibredrv present)
./view_calibre_lvs.sh --bad
./run_calibre_lvs.sh --setup-help

./run_clean.sh
```


Requires [KLayout](https://www.klayout.de/) on `PATH` (`../scripts/install-klayout.sh`).

```bash
klayout -b \
  -rd input=nmos_demo.gds \
  -rd cell=NMOS_GOOD \
  -rd schematic=nmos.cir \
  -rd lvsdb=nmos_good.lvsdb \
  -r transistor.lvs
```

---

## Files

| File | Role |
|------|------|
| `generate_layout.rb` | Builds `nmos_demo.gds` (GOOD + BAD + DEMO) |
| `nmos_demo.gds` | Test layout |
| `nmos.cir` | Reference SPICE (subcircuits match cell names) |
| `transistor.lvs` | KLayout extract + connect + `compare` |
| `transistor.calibre.svrf` | Calibre SVRF rules (`DEVICE MN(NMOS)`) |
| `run_lvs.sh` | Generate + run KLayout GOOD/BAD |
| `run_calibre_lvs.sh` | Generate + run Calibre GOOD/BAD |
| `view_lvs.sh` | `klayout gds -mn lvsdb` |
| `view_calibre_lvs.sh` | Print Calibre report (+ optional RVE) |
| `run_clean.sh` | Delete reports / extracted netlists (`--gds` removes GDS) |

Generated (gitignored): `nmos_{good,bad}.{lvsdb,l2ndb,log}`, `nmos_*_extracted.cir`, `calibre_lvs_{good,bad}.{rep,log,txt,sp}`, `.calibre_lvs_run/`

---

## Layers

| GDS | Name | Screenshot color | Role |
|-----|------|------------------|------|
| 1/0 | DIFF | red | n-active |
| 2/0 | POLY | green | gate |
| 3/0 | CONT | yellow | contacts |
| 4/0 | METAL1 | blue | routing |
| 4/1 | labels | purple | net names S / G / D / B |
| 6/0 | PTIE | orange | substrate tap (bulk) |

---

## How `transistor.lvs` works

### Derived layers

```ruby
gate = diff & poly    # channel
nsd  = diff - poly    # source / drain
```

### Extract MOS4

```ruby
bulk = polygon_layer   # empty — terminal provisioning only (KLayout manual style)

extract_devices(mos4("NMOS"), {
  "SD" => nsd, "G" => gate, "W" => bulk,
  "tS" => nsd, "tD" => nsd, "tG" => poly, "tW" => bulk
})
```

### Connectivity

```ruby
connect(nsd, cont)
connect(poly, cont)
connect(ptie, cont)
connect(cont, metal1)
connect(metal1, m1_lbl)

connect_global(bulk, "SUBSTRATE")
connect_global(ptie, "SUBSTRATE")   # body tap → pin B
```

Do **not** draw a bulk polygon under S/G/D contacts — every contact would short through bulk.

### Compare

```ruby
schematic("nmos.cir")
align
netlist.simplify
ok = compare
puts ok ? "LVS PASS — ..." : "LVS FAIL — ..."
```

Reference:

```spice
.SUBCKT NMOS_GOOD S G D B
M1 D G S B NMOS L=0.18U W=0.50U
.ENDS
```

(`NMOS_BAD` uses the same device connectivity in the schematic; the layout short causes the mismatch.)

---

## Good vs bad extraction

| GOOD (`NMOS_GOOD`) | BAD (`NMOS_BAD`) |
|:------------------:|:----------------:|
| ![GOOD NMOS](../screenshots/lvs_nmos_good.png) | ![BAD NMOS with S–D short](../screenshots/lvs_nmos_bad.png) |
| Separate S / G / D / B | Metal strap shorts S–D |

| GOOD terminals + L/W | BAD + short highlight |
|:--------------------:|:---------------------:|
| ![GOOD zoom](../screenshots/lvs_case_terminals_good.png) | ![BAD zoom](../screenshots/lvs_case_terminals_bad.png) |

**GOOD** — four nets:

```spice
* pin G / S / D / B
M$1 3 1 2 4 NMOS L=0.18U W=0.5U    # D G S B
```

**BAD** — S and D merged:

```spice
* pin G / D,S / B
M$1 2 1 2 3 NMOS L=0.18U W=0.5U    # S/D shorted → FAIL
```

---

## Per-feature zoom (rulers + markers)

Same style as [`../drc/`](../drc/) — zoomed shots with dimension labels. BAD cases highlight the S–D metal bridge (magenta).

### Channel L / W (matches schematic)

![Channel L=0.18 W=0.50](../screenshots/lvs_case_channel_lw.png)

### Terminals (GOOD)

| Gate | Source | Drain | Bulk |
|:----:|:------:|:-----:|:----:|
| ![G](../screenshots/lvs_case_gate.png) | ![S](../screenshots/lvs_case_source.png) | ![D](../screenshots/lvs_case_drain.png) | ![B](../screenshots/lvs_case_bulk.png) |

### S–D connectivity

| GOOD — open (no bridge) | BAD — metal short |
|:-----------------------:|:-----------------:|
| ![S/D separate](../screenshots/lvs_case_sd_separate.png) | ![S/D short](../screenshots/lvs_case_sd_short.png) |

---

## Screenshots

```bash
../scripts/run_capture_screenshots.sh   # regenerate GDS + LVS + all PNGs
```

| File | Content |
|------|---------|
| [`../screenshots/lvs_nmos_demo.png`](../screenshots/lvs_nmos_demo.png) | GOOD + BAD side by side |
| [`../screenshots/lvs_nmos_good.png`](../screenshots/lvs_nmos_good.png) | Passing transistor |
| [`../screenshots/lvs_nmos_bad.png`](../screenshots/lvs_nmos_bad.png) | Failing S–D short |
| `lvs_case_*.png` | Per-feature zoom with rulers / markers (see above) |

---

## KLayout vs Calibre

Verified on this host (Calibre **v2019.2**): `./run_calibre_lvs.sh` → **GOOD PASS** / **BAD FAIL**.

| | KLayout | Calibre |
|---|---------|---------|
| Language | Ruby (`.lvs`) | SVRF (`.svrf`) |
| Device | `extract_devices(mos4("NMOS"), …)` | `DEVICE MN(NMOS) GATE POLY(G) NSD(S) NSD(D) PSUB(B)` |
| Bulk | empty `polygon_layer` + `connect_global(…, "SUBSTRATE")` | `PSUB = EXTENT` + `CONNECT PTIE PSUB` |
| Ports | `labels(4, 1)` + `connect(metal1, m1_lbl)` | `LAYER M1 4` (all datatypes) + `TEXT`/`PORT LAYER TEXT M1` |
| L/W | `tolerance("NMOS", "L"/"W", 0.01)` | `TRACE PROPERTY … 1e-8 ABSOLUTE` (meters) |
| Compare | `schematic` + `compare` | `SOURCE PATH` / `SOURCE PRIMARY` in run deck |
| Viewer | `klayout gds -mn *.lvsdb` | `calibre_lvs_*.txt` / `.rep` |

### Calibre setup

```bash
ln -sf ../drc/calibre.env calibre.env   # or: cp ../drc/calibre.env.example calibre.env
./run_calibre_lvs.sh              # GOOD → PASS, BAD → FAIL
./view_calibre_lvs.sh             # GOOD summary / RVE
./view_calibre_lvs.sh --bad --no-gui
./run_calibre_lvs.sh --setup-help
```

Rules file has **no** layout/source paths — `run_calibre_lvs.sh` writes a temp deck that `INCLUDE`s `transistor.calibre.svrf`.

```svrf
// transistor.calibre.svrf (excerpt)
LAYER M1 4                    // polygons 4/0 + labels 4/1
TEXT LAYER M1
PORT LAYER TEXT M1
GATE = DIFF AND POLY
NSD  = DIFF NOT POLY
PSUB = EXTENT
CONNECT M1 POLY NSD PTIE BY CONT
CONNECT PTIE PSUB
DEVICE MN(NMOS) GATE POLY(G) NSD(S) NSD(D) PSUB(B)
[
  PROPERTY L, W
  L = (PERIMETER(GATE) - PERIMETER_COINCIDE(GATE, NSD)) / 2
  W = PERIMETER_COINCIDE(GATE, NSD) / 2
]
TRACE PROPERTY MN(NMOS) L L 1e-8 ABSOLUTE
TRACE PROPERTY MN(NMOS) W W 1e-8 ABSOLUTE
```

**Extracted (Calibre `-spice`):**

| Cell | Layout netlist | Compare |
|------|----------------|---------|
| GOOD | `M0 D G S B NMOS L=1.8e-07 W=5e-07` | **CORRECT** |
| BAD | `M0 D G D B …` (S–D short; ports `D G B`) | **INCORRECT** |

Reports: `calibre_lvs_{good,bad}.txt` (+ `.rep` / `.sp` / `.log`).

---

## See also

- [`../docs/LVS.md`](../docs/LVS.md) — KLayout LVS reference  
- [`../drc/`](../drc/) — M1 / Contact DRC (KLayout + Calibre)  
- [`../pex/`](../pex/) — M1 resistor PEX  
- [KLayout LVS introduction](https://www.klayout.de/doc-qt5/manual/lvs_intro.html)
