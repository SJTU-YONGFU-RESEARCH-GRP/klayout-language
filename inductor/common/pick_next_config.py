#!/usr/bin/env python3
"""Pick the next inductor run config with mandatory shape rotation.

Rules (create-inductor):
1. New shape MUST differ from the previous run (highest N).
2. Prefer shapes never used yet (order: square → octagon → circle → figure8).
3. Else least-recently-used shape that still allows a fresh (shape, ports, role).
4. Never reuse an existing (shape, ports, role) triple.

Usage:
  python3 inductor/common/pick_next_config.py --root inductor
  python3 inductor/common/pick_next_config.py --root inductor --write inductor/8/config.yaml
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("need PyYAML", file=sys.stderr)
    sys.exit(2)

SHAPES = ["square", "octagon", "circle", "figure8"]

# What the generator actually supports today (expand as features land)
SUPPORTED: dict[str, list[tuple[int, str]]] = {
    "square": [
        (2, "inductor"),
        (3, "inductor"),
        (4, "transformer"),
        (4, "coupler"),
        (4, "balun"),
    ],
    "octagon": [
        (2, "inductor"),
        (3, "inductor"),
        (4, "transformer"),
        (4, "coupler"),
    ],
    "circle": [
        (2, "inductor"),
        (3, "inductor"),
        (4, "transformer"),
        (4, "coupler"),
    ],
    # figure8 path is a dedicated 2-port series topology only
    "figure8": [
        (2, "inductor"),
    ],
}


def load_runs(root: Path) -> list[tuple[int, dict]]:
    runs = []
    for p in root.iterdir():
        if not p.is_dir() or not p.name.isdigit():
            continue
        cfg = p / "config.yaml"
        if not cfg.is_file():
            continue
        data = yaml.safe_load(cfg.read_text()) or {}
        runs.append((int(p.name), data))
    runs.sort(key=lambda t: t[0])
    return runs


def pick(runs: list[tuple[int, dict]]) -> dict:
    used_triples = {
        (str(c.get("shape")), int(c.get("ports", 2)), str(c.get("role", "inductor")))
        for _, c in runs
    }
    used_shapes = [str(c.get("shape")) for _, c in runs]
    prev_shape = used_shapes[-1] if used_shapes else None
    shape_last_idx = {s: -1 for s in SHAPES}
    for i, s in enumerate(used_shapes):
        if s in shape_last_idx:
            shape_last_idx[s] = i

    # 1) unused shapes (canonical order), excluding previous
    unused = [s for s in SHAPES if s not in set(used_shapes) and s != prev_shape]
    # 2) else LRU among shapes ≠ previous
    if unused:
        shape_order = unused
    else:
        shape_order = sorted(
            [s for s in SHAPES if s != prev_shape],
            key=lambda s: (shape_last_idx[s], SHAPES.index(s)),
        )

    for shape in shape_order:
        for ports, role in SUPPORTED.get(shape, []):
            triple = (shape, ports, role)
            if triple in used_triples:
                continue
            n_layers = 1 if ports == 2 and role == "inductor" and shape == "square" else 2
            name = f"{shape}_{ports}p"
            if role == "inductor" and ports == 3:
                name += "_ct"
            elif role != "inductor":
                name += f"_{role[:4]}"
            name += f"_l{n_layers}"
            cell = f"IND_{shape[:3].upper()}_{ports}P"
            return {
                "name": name,
                "cell": cell,
                "shape": shape,
                "ports": ports,
                "role": role,
                "n_layers": n_layers,
                "width_um": 1.0,
                "space_um": 1.0,
                "turns": 2.5 if shape == "figure8" else (3.0 if ports >= 3 else 3.5),
                "inner_radius_um": 16.0 if ports == 3 else (12.0 if shape == "figure8" else 18.0),
                "via_size_um": 0.6,
                "via_enc_um": 0.2,
                "em": {
                    "f_start_hz": 1.0e8,
                    "f_stop_hz": 4.0e10,
                    "f_ref_hz": 2.4e9,
                    "metal_thickness_um": 3.0,
                    "via_height_um": 0.5,
                    "conductivity": 5.8e7,
                    "oxide_eps_r": 3.9,
                    "oxide_thickness_um": 4.0,
                    "n_freq": 101,
                },
                "_meta": {
                    "prev_shape": prev_shape,
                    "reason": (
                        f"unused shape {shape}"
                        if shape not in set(used_shapes)
                        else f"LRU shape {shape} (≠ prev {prev_shape})"
                    ),
                },
            }

    raise SystemExit(
        "No valid (shape, ports, role) left that differs from previous shape. "
        "Add shapes or roles, or retire old runs."
    )


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--root", default="inductor", type=Path)
    ap.add_argument("--write", type=Path, help="Write config.yaml here (creates parent dirs)")
    ap.add_argument("--json", action="store_true", help="Print full config as JSON")
    args = ap.parse_args()
    root = args.root if args.root.is_absolute() else Path.cwd() / args.root
    runs = load_runs(root)
    cfg = pick(runs)
    meta = cfg.pop("_meta")
    print(
        f"pick: shape={cfg['shape']} ports={cfg['ports']} role={cfg['role']} "
        f"({meta['reason']}; prev_shape={meta['prev_shape']})"
    )
    if args.write:
        args.write.parent.mkdir(parents=True, exist_ok=True)
        args.write.write_text(yaml.safe_dump(cfg, sort_keys=False))
        print(f"wrote {args.write}")
    elif args.json:
        import json

        print(json.dumps(cfg, indent=2))
    else:
        print(yaml.safe_dump(cfg, sort_keys=False), end="")


if __name__ == "__main__":
    main()
