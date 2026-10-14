# klayout-language

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-green?logo=creativecommons&logoColor=white)](https://creativecommons.org/licenses/by/4.0/)
[![GitHub](https://img.shields.io/badge/GitHub-klayout--language-181717?logo=github)](https://github.com/SJTU-YONGFU-RESEARCH-GRP/klayout-language)

**Repository:** [SJTU-YONGFU-RESEARCH-GRP/klayout-language](https://github.com/SJTU-YONGFU-RESEARCH-GRP/klayout-language)

KLayout **DRC / LVS / PEX** language notes and runnable demos (GOOD pass / BAD fail), plus an on-chip **inductor** design flow (layout → DRC/LVS → EM).

- **License**: CC BY 4.0 (see `LICENSE`)
- **Entry points**: `drc/`, `lvs/`, `pex/`, `inductor/`, `scripts/`

## Table of contents

- [Features](#features)
- [Requirements](#requirements)
- [Quick start](#quick-start)
  - [Install tools](#install-tools)
  - [DRC](#drc)
  - [LVS](#lvs)
  - [PEX](#pex)
  - [Inductor flow](#inductor-flow)
  - [Screenshots](#screenshots)
- [Docs](#docs)
- [Demos](#demos)
- [Project layout](#project-layout)
- [License](#license)
- [References](#references)

## Features

| Area | What you get |
|------|----------------|
| **Docs** | Command-oriented notes for DRC, LVS, and built-in PEX APIs under [`docs/`](docs/) |
| **DRC demo** | Metal1 / Contact width, space, enclosure — KLayout and optional Calibre |
| **LVS demo** | Single NMOS (`mos4`) vs SPICE — PASS / FAIL (S–D short); optional Calibre |
| **PEX demo** | Resistance (`RNetExtractor`), overlap C (LVS `capacitor`), coupling CC ([kpex](https://iic-jku.github.io/klayout-pex-website/doc/doc.html) 2.5D); optional Calibre xRC |
| **Inductor** | Generate GDS from YAML, DRC/LVS, screenshot, PEEC/openEMS, per-run `RESULT.md` and [`inductor/BENCHMARK.md`](inductor/BENCHMARK.md) |

## Requirements

- [KLayout](https://www.klayout.de/) on `PATH` — **0.30.2+** for built-in `RNetExtractor` / PEX API (installer defaults to 0.30.12)
- Bash and a normal Unix shell for the `run_*.sh` / `view_*.sh` scripts
- **Optional — Calibre**: site `calibre.env` (see `drc/calibre.env.example`) for Calibre DRC / LVS / xRC scripts
- **Optional — kpex**: Python **≥ 3.12** and [`scripts/install_kpex.sh`](scripts/install_kpex.sh)
- **Optional — openEMS**: [`scripts/install-openems.sh`](scripts/install-openems.sh) for FDTD in the inductor flow (PEEC fallback if openEMS is missing)

## Quick start

### Install tools

```bash
git clone https://github.com/SJTU-YONGFU-RESEARCH-GRP/klayout-language.git
cd klayout-language

./scripts/install-klayout.sh
# optional:
./scripts/install_kpex.sh
./scripts/install-openems.sh --deps --disable-gui
```

### DRC

```bash
cd drc
./run_klayout_drc.sh && ./view_klayout_drc.sh
# optional Calibre (needs calibre.env):
./run_calibre_drc.sh
```

Details: [`drc/README.md`](drc/README.md).

### LVS

```bash
cd lvs
./run_lvs.sh && ./view_lvs.sh
# optional Calibre (needs calibre.env like drc/):
./run_calibre_lvs.sh
```

Details: [`lvs/README.md`](lvs/README.md).

### PEX

```bash
cd pex
./run_pex.sh && ./view_pex.sh

# optional Calibre xRC R + DEVICE CAP C (needs calibre.env like drc/)
./run_calibre_pex.sh

# coupling capacitance (kpex 2.5D, sky130A)
../scripts/install_kpex.sh    # once, Python >= 3.12
./run_kpex.sh
```

Details: [`pex/README.md`](pex/README.md).

### Inductor flow

```bash
python3 inductor/common/generate_inductor.py \
  --config inductor/1/config.yaml \
  --out inductor/1/layout/inductor.gds

./inductor/common/run_drc.sh inductor/1
./inductor/common/run_lvs.sh inductor/1
./inductor/common/run_screenshot.sh inductor/1
./inductor/common/run_openems.sh inductor/1
./inductor/common/run_benchmark.sh
```

Details: [`inductor/README.md`](inductor/README.md).

### Screenshots

```bash
./scripts/run_capture_screenshots.sh
```

Regenerates images under [`screenshots/`](screenshots/) (Xvfb + colored layers + rulers).

## Docs

| Doc | Contents |
|-----|----------|
| [`docs/DRC.md`](docs/DRC.md) | KLayout DRC command reference |
| [`docs/LVS.md`](docs/LVS.md) | KLayout LVS command reference |
| [`docs/PEX.md`](docs/PEX.md) | Built-in `RNetExtractor` / `RExtractor` reference |

## Demos

| Demo | What it shows |
|------|----------------|
| [`drc/`](drc/) | M1 / Contact **width, space, enclosure** — GOOD pass / BAD fail (KLayout + Calibre) |
| [`lvs/`](lvs/) | Single **NMOS** transistor LVS — GOOD pass / BAD (S–D short) fail (KLayout + Calibre) |
| [`pex/`](pex/) | **R** + overlap **C** (KLayout **or** Calibre) + sidewall **CC** (kpex 2.5D) — GOOD pass / BAD fail |
| [`inductor/`](inductor/) | On-chip inductor generate → DRC/LVS → EM → `RESULT.md` / `BENCHMARK.md` |

![DRC test layout](screenshots/drc_m1_contact_layout.png)

![LVS GOOD vs BAD NMOS](screenshots/lvs_nmos_demo.png)

![PEX R GOOD vs BAD](screenshots/pex_r_demo.png)

![PEX C GOOD vs BAD](screenshots/pex_c_demo.png)

![PEX CC GOOD vs BAD](screenshots/pex_cc_demo.png)

## Project layout

```text
klayout-language/
├── docs/                 # DRC / LVS / PEX language notes
├── drc/                  # M1–Contact DRC demo
├── lvs/                  # NMOS LVS demo
├── pex/                  # R / C / CC PEX demos
├── inductor/             # Inductor runs + common tooling
│   ├── common/           # generate, DRC, LVS, EM, benchmark scripts
│   ├── BENCHMARK.md
│   └── <N>/              # per-design config, layout, drc, lvs, sim, RESULT.md
├── plugins/              # KLayout macros (e.g. save_screenshot)
├── screenshots/          # Demo PNGs for docs / README
├── scripts/              # install-klayout, kpex, openEMS, screenshot capture
├── LICENSE
└── README.md
```

## License

This project is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). See [LICENSE](LICENSE).

**Third-party tools** (KLayout, Calibre, kpex, openEMS, PDKs such as sky130A) remain under their respective licenses and site terms.

## References

- [KLayout](https://www.klayout.de/) — layout viewer and DRC/LVS engine
- [KLayout-PEX (kpex)](https://iic-jku.github.io/klayout-pex-website/doc/doc.html) — 2.5D parasitic extraction
- [openEMS](https://docs.openems.de/) — FDTD EM solver (optional for inductor runs)
