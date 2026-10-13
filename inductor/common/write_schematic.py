#!/usr/bin/env python3
"""Write SPICE schematic for inductor LVS from config.yaml."""
from __future__ import annotations

import argparse
from pathlib import Path

import yaml


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    cfg = yaml.safe_load(Path(args.config).read_text())
    cell = cfg["cell"]
    ports = int(cfg.get("ports", 2))
    role = cfg.get("role", "inductor")

    lines = [f"* Auto schematic for {cell} ({role})", f".SUBCKT {cell}"]

    if ports == 2:
        lines[1] = f".SUBCKT {cell} P1 P2"
        lines.append("Rwind P1 P2 0.01")
    elif ports == 3:
        lines[1] = f".SUBCKT {cell} P1 P2 CT"
        lines.append("Ra P1 CT 0.01")
        lines.append("Rb CT P2 0.01")
    else:
        lines[1] = f".SUBCKT {cell} P1 P2 S1 S2"
        lines.append("Rpri P1 P2 0.01")
        lines.append("Rsec S1 S2 0.01")
        # no DC path between primary and secondary

    lines.append(".ENDS")
    lines.append("")

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(lines))
    print(f"Wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
