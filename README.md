# klayout-language

KLayout DRC / LVS language notes and runnable demos.

## Docs

| Doc | Contents |
|-----|----------|
| [`docs/DRC.md`](docs/DRC.md) | KLayout DRC command reference |
| [`docs/LVS.md`](docs/LVS.md) | KLayout LVS command reference |
| [`docs/PEX.md`](docs/PEX.md) | PEX notes |

## Demos

| Demo | What it shows |
|------|----------------|
| [`drc/`](drc/) | M1 / Contact **width, space, enclosure** — GOOD pass / BAD fail (KLayout + Calibre) |
| [`lvs/`](lvs/) | Single **NMOS** transistor LVS — GOOD pass / BAD (S–D short) fail |

![DRC test layout](screenshots/drc_m1_contact_layout.png)

![LVS GOOD vs BAD NMOS](screenshots/lvs_nmos_demo.png)

```bash
# DRC
cd drc && ./run_klayout_drc.sh && ./view_klayout_drc.sh

# LVS
cd lvs && ./run_lvs.sh && ./view_lvs.sh

# Regenerate README screenshots (Xvfb + colored layers + DRC markers)
./scripts/run_capture_screenshots.sh
```

Install KLayout (if needed): [`scripts/install-klayout.sh`](scripts/install-klayout.sh).
