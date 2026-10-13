#!/usr/bin/env python3
"""Generate inductor GDS from config.yaml via KLayout Ruby deck."""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    import yaml
except ImportError as e:
    raise SystemExit("PyYAML required: pip install pyyaml") from e

ROOT = Path(__file__).resolve().parent
RUBY = ROOT / "generate_inductor.rb"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--config", required=True, help="path to config.yaml")
    ap.add_argument("--out", required=True, help="output .gds path")
    ap.add_argument("--klayout", default="klayout", help="klayout binary")
    args = ap.parse_args()

    cfg_path = Path(args.config).resolve()
    out_path = Path(args.out).resolve()
    out_path.parent.mkdir(parents=True, exist_ok=True)

    with cfg_path.open() as f:
        cfg = yaml.safe_load(f)

    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as tf:
        json.dump(cfg, tf)
        json_path = tf.name

    cmd = [
        args.klayout,
        "-b",
        "-r",
        str(RUBY),
        "-rd",
        f"config={json_path}",
        "-rd",
        f"output={out_path}",
    ]
    print("+", " ".join(cmd))
    r = subprocess.run(cmd, check=False)
    Path(json_path).unlink(missing_ok=True)
    if r.returncode != 0:
        return r.returncode
    if not out_path.is_file():
        print(f"ERROR: GDS not written: {out_path}", file=sys.stderr)
        return 1
    print(f"OK {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
