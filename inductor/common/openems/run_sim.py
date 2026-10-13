#!/usr/bin/env python3
"""
openEMS inductor simulation driver.

Exports S-parameters and rough L/Q vs frequency into the run's sim/ folder.
If openEMS/CSXCAD are not installed, exits 2 (caller marks SKIPPED).
"""
from __future__ import annotations

import argparse
import csv
import math
import sys
from pathlib import Path

import yaml


def try_import_openems():
    try:
        from openEMS import openEMS  # noqa: F401
        from openEMS.physical_constants import C0  # noqa: F401
        from CSXCAD import ContinuousStructure  # noqa: F401
        return True
    except Exception as e:
        print(f"openEMS not available: {e}", file=sys.stderr)
        return False


def analytic_fallback(cfg: dict, sim_dir: Path) -> None:
    """
    First-order square-spiral estimate (Greenhouse-like) when EM is unavailable.
    Used only to keep the pipeline producing files; RESULT.md must say SKIPPED/approx.
    """
    w = float(cfg.get("width_um", 1.0))
    s = float(cfg.get("space_um", 1.0))
    n = float(cfg.get("turns", 3.5))
    rin = float(cfg.get("inner_radius_um", 20.0))
    # average diameter (µm) → nH rough
    d_avg = 2 * (rin + n * (w + s) / 2)
    rho = (d_avg - n * (w + s)) / (d_avg + n * (w + s))
    L_nh = 1.27e-3 * d_avg * n**2 * (math.log(2.07 / rho) + 0.18 * rho + 0.13 * rho**2)

    em = cfg.get("em") or {}
    f0 = float(em.get("f_ref_hz", 2.4e9))
    f_start = float(em.get("f_start_hz", 1e8))
    f_stop = float(em.get("f_stop_hz", 2e10))

    s_path = sim_dir / "sparams.csv"
    lq_path = sim_dir / "lq.csv"
    with s_path.open("w", newline="") as f:
        wri = csv.writer(f)
        wri.writerow(["freq_hz", "S11_re", "S11_im", "S21_re", "S21_im", "note"])
        for i in range(21):
            freq = f_start + (f_stop - f_start) * i / 20
            # stub: weak frequency dependence placeholder
            wri.writerow([f"{freq:.6e}", -0.1, 0.0, 0.9, 0.0, "placeholder_no_openems"])

    with lq_path.open("w", newline="") as f:
        wri = csv.writer(f)
        wri.writerow(["freq_hz", "L_H", "Q", "R_ohm", "note"])
        for i in range(21):
            freq = f_start + (f_stop - f_start) * i / 20
            # crude skin-effect-ish R growth
            r = 1.0 * math.sqrt(freq / f0)
            q = (2 * math.pi * freq * L_nh * 1e-9) / max(r, 1e-6)
            wri.writerow([f"{freq:.6e}", f"{L_nh*1e-9:.6e}", f"{q:.3f}", f"{r:.4f}", "analytic_approx"])

    (sim_dir / "STATUS.txt").write_text(
        "SKIPPED_OPENEMS\nanalytic Greenhouse-like L estimate written to lq.csv\n"
        f"L_est_nH={L_nh:.4f}\n"
    )
    print(f"Wrote analytic placeholders under {sim_dir} (L≈{L_nh:.3f} nH)")


def run_openems(cfg: dict, gds: Path, sim_dir: Path) -> None:
    """
    Minimal broadband 2-port setup. Geometry is a bounding-box metal plate
    proxy unless a full GDS→CSX importer is added later.
    """
    from openEMS import openEMS
    from openEMS.physical_constants import C0
    from CSXCAD import ContinuousStructure

    em = cfg.get("em") or {}
    f_start = float(em.get("f_start_hz", 1e8))
    f_stop = float(em.get("f_stop_hz", 2e10))
    unit = 1e-6

    CSX = ContinuousStructure()
    FDTD = openEMS(NrTS=2e5, EndCriteria=1e-4)
    FDTD.SetCSX(CSX)
    FDTD.SetGaussExcite(0.5 * (f_start + f_stop), 0.5 * (f_stop - f_start))
    FDTD.SetBoundaryCond(["PML_8"] * 6)

    # Placeholder brick — replace with polygon import from GDS in future revisions
    rin = float(cfg.get("inner_radius_um", 20.0))
    turns = float(cfg.get("turns", 3.5))
    pitch = float(cfg.get("width_um", 1.0)) + float(cfg.get("space_um", 1.0))
    extent = rin + turns * pitch + 30
    th = float(em.get("metal_thickness_um", 0.5))
    metal = CSX.AddMetal("copper")
    metal.AddBox([ -extent, -extent, 0], [extent, extent, th])

    mesh = CSX.GetGrid()
    mesh.SetDeltaUnit(unit)
    for ax, lim in enumerate([extent + 50] * 3):
        mesh.AddLine(ax, [-lim, lim])
    mesh.SmoothMeshLines("all", float(cfg.get("width_um", 1.0)) * float(em.get("mesh_fraction_of_width", 0.25)), 1.4)

    sim_dir.mkdir(parents=True, exist_ok=True)
    FDTD.Run(str(sim_dir / "openems_data"), verbose=False, cleanup=True)

    # Without detailed ports, write status only
    (sim_dir / "STATUS.txt").write_text(
        "OPENEMS_RAN_PLACEHOLDER_GEOMETRY\n"
        "Full spiral port extraction not yet wired; replace metal box with GDS polygons.\n"
        f"gds={gds}\n"
    )
    print("openEMS placeholder run finished — refine geometry import for production Q/S")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--gds", required=True)
    ap.add_argument("--sim-dir", required=True)
    ap.add_argument("--allow-analytic", action="store_true",
                    help="if openEMS missing, write analytic L/Q placeholders")
    args = ap.parse_args()

    cfg = yaml.safe_load(Path(args.config).read_text())
    sim_dir = Path(args.sim_dir)
    sim_dir.mkdir(parents=True, exist_ok=True)
    gds = Path(args.gds)

    if try_import_openems():
        run_openems(cfg, gds, sim_dir)
        return 0

    if args.allow_analytic:
        analytic_fallback(cfg, sim_dir)
        return 0

    print("Install openEMS+CSXCAD or re-run with --allow-analytic", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
