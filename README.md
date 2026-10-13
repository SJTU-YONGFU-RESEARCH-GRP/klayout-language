# klayout-language

KLayout DRC / LVS / PEX language notes and runnable demos.

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
| [`lvs/`](lvs/) | Single **NMOS** transistor LVS — GOOD pass / BAD (S–D short) fail |
| [`pex/`](pex/) | **R** (`RNetExtractor`) + **C** (`capacitor()` overlap) — GOOD pass / BAD fail |

![DRC test layout](screenshots/drc_m1_contact_layout.png)

![LVS GOOD vs BAD NMOS](screenshots/lvs_nmos_demo.png)

![PEX R GOOD vs BAD](screenshots/pex_r_demo.png)

![PEX C GOOD vs BAD](screenshots/pex_c_demo.png)

```bash
# DRC
cd drc && ./run_klayout_drc.sh && ./view_klayout_drc.sh

# LVS
cd lvs && ./run_lvs.sh && ./view_lvs.sh

# PEX
cd pex && ./run_pex.sh && ./view_pex.sh

# Regenerate README screenshots (Xvfb + colored layers + rulers)
./scripts/run_capture_screenshots.sh
```

Install KLayout (if needed): [`scripts/install-klayout.sh`](scripts/install-klayout.sh). Needs **0.30.2+** for the built-in PEX API.
