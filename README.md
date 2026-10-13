# klayout-language

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-green?logo=creativecommons&logoColor=white)](https://creativecommons.org/licenses/by/4.0/)
[![KLayout](https://img.shields.io/badge/KLayout-0.30+-blue.svg)](https://www.klayout.de/)

**Repository:** [SJTU-YONGFU-RESEARCH-GRP/klayout-language](https://github.com/SJTU-YONGFU-RESEARCH-GRP/klayout-language)

KLayout **DRC / LVS / PEX** language notes and runnable demos: command references extracted from the official docs, side-by-side GOOD/BAD layouts, and optional Calibre comparison for DRC.

- **License**: CC BY 4.0 (see [`LICENSE`](LICENSE))
- **Upstream**: [KLayout](https://www.klayout.de/) DRC/LVS reference and built-in macros (0.30.2+)

## Table of contents

- [Features](#features)
- [Requirements](#requirements)
- [Quick start](#quick-start)
  - [Install KLayout](#install-klayout)
  - [DRC demo](#drc-demo)
  - [LVS demo](#lvs-demo)
  - [PEX demo](#pex-demo)
  - [Screenshots](#screenshots)
- [Docs](#docs)
- [Demos](#demos)
- [Project layout](#project-layout)
- [License](#license)
- [References](#references)

## Features

| Area | What you get |
|------|----------------|
| **Docs** | Command references for DRC, LVS, and PEX (`docs/`) |
| **DRC** | M1 / Contact width, space, enclosure — KLayout + optional Calibre |
| **LVS** | Single NMOS `mos4` extract vs SPICE — GOOD pass / BAD S–D short |
| **PEX** | M1 resistor sheet-R extract — GOOD low R / BAD high R |
| **Inductor** | On-chip inductor generate → DRC → LVS → openEMS flow |
| **Plugin** | Save Layout Screenshot menu macro |

## Requirements

- [KLayout](https://www.klayout.de/) on `PATH` (0.30+ recommended; demos use batch `-b` / Ruby DSL)
- Bash; optional Calibre for [`drc/`](drc/) comparison (`calibre.env` from `calibre.env.example`)
- Optional: Python 3 for inductor generation; openEMS for EM sims under [`inductor/`](inductor/)

## Quick start

### Install KLayout

```bash
./scripts/install-klayout.sh --user
```

### DRC demo

![M1/Contact DRC layout](screenshots/drc_m1_contact_layout.png)

```bash
cd drc
./run_klayout_drc.sh && ./view_klayout_drc.sh
```

See [`drc/README.md`](drc/README.md) for Calibre batch/UI and rule tables.

### LVS demo

![NMOS LVS GOOD vs BAD](screenshots/lvs_nmos_demo.png)

```bash
cd lvs
./run_lvs.sh && ./view_lvs.sh
```

See [`lvs/README.md`](lvs/README.md) for layers, `transistor.lvs`, and expected PASS/FAIL.

### PEX demo

```bash
cd pex
./run_pex.sh              # GOOD → PASS, BAD → FAIL
./run_pex.sh --good
./view_pex.sh
```

Sheet resistance defaults: `SHEET_R=0.08` Ω/sq, pass if extracted R &lt; `R_LIMIT=1.0` Ω.

### Screenshots

```bash
./scripts/run_capture_screenshots.sh
```

Regenerates PNGs under [`screenshots/`](screenshots/) (Xvfb + colored layers + DRC markers).

## Docs

| Doc | Contents |
|-----|----------|
| [`docs/DRC.md`](docs/DRC.md) | KLayout DRC command reference |
| [`docs/LVS.md`](docs/LVS.md) | KLayout LVS command reference |
| [`docs/PEX.md`](docs/PEX.md) | PEX / `klayout.pex` notes |

## Demos

| Demo | What it shows |
|------|----------------|
| [`drc/`](drc/) | M1 / Contact **width, space, enclosure** — GOOD pass / BAD fail (KLayout + Calibre) |
| [`lvs/`](lvs/) | Single **NMOS** transistor LVS — GOOD pass / BAD (S–D short) fail |
| [`pex/`](pex/) | M1 **resistor** PEX — GOOD low R / BAD high R vs sheet-R limit |
| [`inductor/`](inductor/) | Inductor layout generation, DRC/LVS, optional openEMS |
| [`plugins/save_screenshot/`](plugins/save_screenshot/) | KLayout menu macro to export PNG screenshots |

## Project layout

```text
klayout-language/
├── docs/                 # DRC / LVS / PEX command references
├── drc/                  # M1/Contact DRC demo (KLayout + Calibre)
├── lvs/                  # NMOS LVS demo
├── pex/                  # M1 resistor PEX demo
├── inductor/             # Inductor design runs + common tooling
├── plugins/              # KLayout pymacro plugins
├── scripts/              # install-klayout, screenshot capture
├── screenshots/          # Demo PNGs for READMEs
├── LICENSE
└── README.md
```

## License

This project is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). See [`LICENSE`](LICENSE).

Third-party tools (KLayout, Calibre, openEMS) remain under their respective licenses.

## References

- [KLayout](https://www.klayout.de/) — layout viewer and DRC/LVS engine
- [KLayout documentation](https://www.klayout.de/doc.html)
- [KLayout downloads / builds](https://www.klayout.de/build.html)
