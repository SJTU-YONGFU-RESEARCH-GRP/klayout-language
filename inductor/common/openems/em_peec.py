#!/usr/bin/env python3
"""
Geometry-based physical EM for on-chip spirals (PEEC / Greenhouse–Grover).

Extracts the GDS centerline, computes:
  - segment self-inductance + mutual inductance between parallels
  - DC + skin-effect resistance
  - simple substrate/oxide shunt C estimate
  - Z(f) → L(f), Q(f), S-parameters (series 2-port in 50 Ω)

Not full-wave FDTD; suitable when openEMS is unavailable. Marked
engine=PEEC_GEOMETRY in STATUS.txt.
"""
from __future__ import annotations

import argparse
import csv
import json
import math
from pathlib import Path

import numpy as np
import yaml

MU0 = 4e-7 * math.pi
EPS0 = 8.854187817e-12
Z0 = 50.0


def seg_self_L(length_m: float, width_m: float, thick_m: float) -> float:
    """Grover self-inductance of a straight rectangular bar (H)."""
    if length_m <= 0:
        return 0.0
    # geometric mean distance approximation for thin ribbon
    a = width_m
    b = max(thick_m, 1e-9)
    # Grover: L = 2e-7 * l * (ln(2l/(w+t)) + 0.5 + 0.2235*(w+t)/l)
    L = 2e-7 * length_m * (
        math.log(2 * length_m / (a + b)) + 0.5 + 0.2235 * (a + b) / length_m
    )
    return max(L, 0.0)


def mutual_parallel(
    length_m: float, distance_m: float, length2_m: float | None = None
) -> float:
    """Mutual inductance of two parallel filaments (H), same orientation."""
    if length_m <= 0 or distance_m <= 0:
        return 0.0
    l = length_m
    l2 = length2_m if length2_m is not None else length_m
    # use shorter as common overlap approximation
    ell = min(l, l2)
    d = distance_m
    # Rosa/Greenhouse filament mutual
    M = 2e-7 * ell * (
        math.log(ell / d + math.sqrt(1 + (ell / d) ** 2))
        - math.sqrt(1 + (d / ell) ** 2)
        + d / ell
    )
    return max(M, 0.0)


def polyline_segments(pts_um: list[list[float]], width_um: float, thick_um: float):
    """Return list of dicts: x0,y0,x1,y1 (m), length, horiz/vert, mid."""
    segs = []
    w = width_um * 1e-6
    t = thick_um * 1e-6
    for i in range(len(pts_um) - 1):
        x0, y0 = pts_um[i][0] * 1e-6, pts_um[i][1] * 1e-6
        x1, y1 = pts_um[i + 1][0] * 1e-6, pts_um[i + 1][1] * 1e-6
        dx, dy = x1 - x0, y1 - y0
        length = math.hypot(dx, dy)
        if length < 1e-12:
            continue
        horiz = abs(dx) >= abs(dy)
        segs.append(
            {
                "x0": x0,
                "y0": y0,
                "x1": x1,
                "y1": y1,
                "length": length,
                "horiz": horiz,
                "w": w,
                "t": t,
                "mx": 0.5 * (x0 + x1),
                "my": 0.5 * (y0 + y1),
            }
        )
    return segs


def total_inductance(segs) -> float:
    L = 0.0
    for s in segs:
        L += seg_self_L(s["length"], s["w"], s["t"])
    n = len(segs)
    for i in range(n):
        for j in range(i + 1, n):
            a, b = segs[i], segs[j]
            if a["horiz"] != b["horiz"]:
                continue  # orthogonal → neglect mutual
            # signed: same direction vs opposite (return path)
            if a["horiz"]:
                # parallel horizontal: distance in y
                d = abs(a["my"] - b["my"])
                # overlap length along x
                lo = max(min(a["x0"], a["x1"]), min(b["x0"], b["x1"]))
                hi = min(max(a["x0"], a["x1"]), max(b["x0"], b["x1"]))
                overlap = hi - lo
                if overlap <= 0 or d < 1e-12:
                    continue
                # direction sign
                sa = 1.0 if a["x1"] >= a["x0"] else -1.0
                sb = 1.0 if b["x1"] >= b["x0"] else -1.0
                sign = sa * sb
            else:
                d = abs(a["mx"] - b["mx"])
                lo = max(min(a["y0"], a["y1"]), min(b["y0"], b["y1"]))
                hi = min(max(a["y0"], a["y1"]), max(b["y0"], b["y1"]))
                overlap = hi - lo
                if overlap <= 0 or d < 1e-12:
                    continue
                sa = 1.0 if a["y1"] >= a["y0"] else -1.0
                sb = 1.0 if b["y1"] >= b["y0"] else -1.0
                sign = sa * sb
            M = mutual_parallel(overlap, d)
            L += 2.0 * sign * M
    return max(L, 1e-15)


def total_length(segs) -> float:
    return sum(s["length"] for s in segs)


def resistance(segs, freq_hz: float, sigma: float, thick_m: float) -> float:
    """Series R with skin effect (Ω)."""
    length = total_length(segs)
    if not segs:
        return 1e9
    w = segs[0]["w"]
    # skin depth
    delta = math.sqrt(1.0 / (math.pi * freq_hz * MU0 * sigma)) if freq_hz > 0 else thick_m
    t_eff = min(thick_m, delta)
    # current on top/bottom for thick conductors at high f
    if delta < thick_m:
        # approx: two skins
        area = w * delta  # effective
    else:
        area = w * thick_m
    Rdc = length / (sigma * w * thick_m)
    Rac = length / (sigma * max(area, 1e-22))
    return max(Rdc, Rac * 0.5 + Rdc * 0.5) if delta < thick_m else Rdc


def shunt_C(segs, ox_eps_r: float, ox_thick_m: float) -> float:
    """Rough oxide capacitance to substrate from ribbon area (F)."""
    area = sum(s["length"] * s["w"] for s in segs)
    return ox_eps_r * EPS0 * area / max(ox_thick_m, 1e-9)


def z_to_s_series(Z: complex, z0: float = Z0) -> tuple[complex, complex]:
    """Series impedance between port1 and port2 → S11, S21."""
    # T-network with series Z, shunt open
    # S11 = Z / (Z + 2 Z0), S21 = 2 Z0 / (Z + 2 Z0)
    denom = Z + 2 * z0
    s11 = Z / denom
    s21 = 2 * z0 / denom
    return s11, s21


def simulate(cfg: dict, geom: dict, sim_dir: Path) -> dict:
    em = cfg.get("em") or {}
    width_um = float(cfg.get("width_um", geom.get("width_um", 1.0)))
    thick_um = float(em.get("metal_thickness_um", 0.5))
    sigma = float(em.get("conductivity", 5.8e7))
    f_start = float(em.get("f_start_hz", 1e8))
    f_stop = float(em.get("f_stop_hz", 2e10))
    f_ref = float(em.get("f_ref_hz", 2.4e9))
    nfreq = int(em.get("n_freq", 81))
    ox_eps = float(em.get("oxide_eps_r", 3.9))
    ox_t = float(em.get("oxide_thickness_um", 2.0)) * 1e-6

    # Use all centerlines (figure-8 has two) — series sum of L with coupling neglected across loops
    # Better: concatenate primary only for 2p single; for figure8 use longest then add second
    clines = geom.get("centerlines_um") or []
    primary = geom.get("primary_centerline_um") or (clines[0] if clines else [])
    if not primary:
        raise RuntimeError("no centerline in geometry.json — regenerate GDS with 31/2 path")

    segs = polyline_segments(primary, width_um, thick_um)
    # If multiple centerlines (figure-8), add remaining as series (bridge already in path if combined)
    for cl in clines:
        if cl is primary or cl == primary:
            continue
        # only add if substantially different
        if len(cl) < 4:
            continue
        # skip duplicates of primary
        if abs(cl[0][0] - primary[0][0]) < 0.1 and abs(cl[0][1] - primary[0][1]) < 0.1:
            continue
        segs.extend(polyline_segments(cl, width_um, thick_um))

    L0 = total_inductance(segs)
    C = shunt_C(segs, ox_eps, ox_t)
    length_um = total_length(segs) * 1e6

    freqs = np.linspace(f_start, f_stop, nfreq)
    rows_s = []
    rows_lq = []
    for f in freqs:
        w = 2 * math.pi * f
        R = resistance(segs, float(f), sigma, thick_um * 1e-6)
        # series L || with C to gnd at each port → π model approx: Zseries = R+jωL, Yin = jωC/2 each side
        # Effective one-port input with far end grounded through 0: Z = (R+jωL) || 1/(jωC) roughly for SRF
        ZL = R + 1j * w * L0
        # include parallel C across inductor (substrate)
        if C > 0 and abs(1j * w * C) > 0:
            Y = 1.0 / ZL + 1j * w * C
            Z = 1.0 / Y
        else:
            Z = ZL
        s11, s21 = z_to_s_series(Z)
        L_eff = Z.imag / w if w > 0 else L0
        Q = Z.imag / Z.real if Z.real > 1e-12 else 0.0
        rows_s.append(
            [
                f"{f:.6e}",
                f"{s11.real:.8e}",
                f"{s11.imag:.8e}",
                f"{s21.real:.8e}",
                f"{s21.imag:.8e}",
                "PEEC_GEOMETRY",
            ]
        )
        rows_lq.append(
            [
                f"{f:.6e}",
                f"{L_eff:.8e}",
                f"{Q:.4f}",
                f"{Z.real:.6e}",
                "PEEC_GEOMETRY",
            ]
        )

    sim_dir.mkdir(parents=True, exist_ok=True)
    with (sim_dir / "sparams.csv").open("w", newline="") as f:
        wri = csv.writer(f)
        wri.writerow(["freq_hz", "S11_re", "S11_im", "S21_re", "S21_im", "note"])
        wri.writerows(rows_s)
    with (sim_dir / "lq.csv").open("w", newline="") as f:
        wri = csv.writer(f)
        wri.writerow(["freq_hz", "L_H", "Q", "R_ohm", "note"])
        wri.writerows(rows_lq)

    # metrics at f_ref
    idx = int(np.argmin(np.abs(freqs - f_ref)))
    f_i = float(freqs[idx])
    L_i = float(rows_lq[idx][1])
    Q_i = float(rows_lq[idx][2])
    # Qmax
    qs = [float(r[2]) for r in rows_lq]
    imax = int(np.argmax(qs))
    summary = {
        "engine": "PEEC_GEOMETRY",
        "L0_nH": L0 * 1e9,
        "C_fF": C * 1e15,
        "length_um": length_um,
        "n_segments": len(segs),
        "f_ref_hz": f_i,
        "L_at_fref_nH": float(L_i) * 1e9,
        "Q_at_fref": Q_i,
        "Q_max": qs[imax],
        "f_at_Qmax_hz": float(freqs[imax]),
        "SRF_est_GHz": (1.0 / (2 * math.pi * math.sqrt(L0 * C)) / 1e9) if C > 0 else None,
    }
    (sim_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    (sim_dir / "STATUS.txt").write_text(
        "PEEC_GEOMETRY\n"
        "Physical EM from GDS centerline (Grover self + mutual, skin R, oxide C).\n"
        f"L0={summary['L0_nH']:.4f} nH  Q@fref={Q_i:.2f}  Qmax={qs[imax]:.2f}\n"
    )
    print(
        f"PEEC OK  L0={summary['L0_nH']:.3f} nH  "
        f"Q@ref={Q_i:.1f}  Qmax={qs[imax]:.1f} @ {freqs[imax]/1e9:.2f} GHz  "
        f"segs={len(segs)} len={length_um:.1f} µm"
    )
    return summary


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--geometry", required=True)
    ap.add_argument("--sim-dir", required=True)
    args = ap.parse_args()
    cfg = yaml.safe_load(Path(args.config).read_text())
    geom = json.loads(Path(args.geometry).read_text())
    simulate(cfg, geom, Path(args.sim_dir))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
