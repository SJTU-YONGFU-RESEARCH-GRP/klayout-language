#!/usr/bin/env python3
"""Plot inductor EM results: L(f), Q(f), |S11|, |S21|."""
from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def load_csv(path: Path):
    with path.open() as f:
        rows = list(csv.DictReader(f))
    return rows


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--sim-dir", required=True)
    ap.add_argument("--title", default="Inductor EM")
    args = ap.parse_args()
    sim = Path(args.sim_dir)
    lq = load_csv(sim / "lq.csv")
    sp = load_csv(sim / "sparams.csv")
    summary = {}
    sj = sim / "summary.json"
    if sj.is_file():
        summary = json.loads(sj.read_text())

    f = np.array([float(r["freq_hz"]) for r in lq])
    L_nH = np.array([float(r["L_H"]) for r in lq]) * 1e9
    Q = np.array([float(r["Q"]) for r in lq])
    s11 = np.array([complex(float(r["S11_re"]), float(r["S11_im"])) for r in sp])
    s21 = np.array([complex(float(r["S21_re"]), float(r["S21_im"])) for r in sp])
    f_g = f / 1e9

    fig, axs = plt.subplots(2, 2, figsize=(10, 7.5), constrained_layout=True)
    fig.suptitle(args.title, fontsize=13, fontweight="bold")

    ax = axs[0, 0]
    ax.plot(f_g, L_nH, color="#1565C0", lw=2)
    ax.set_xlabel("Frequency (GHz)")
    ax.set_ylabel("L (nH)")
    ax.set_title("Inductance")
    ax.grid(True, alpha=0.3)
    if summary.get("f_ref_hz"):
        ax.axvline(summary["f_ref_hz"] / 1e9, color="#E63900", ls="--", lw=1, label="f_ref")
        ax.legend(loc="best", fontsize=8)

    ax = axs[0, 1]
    ax.plot(f_g, Q, color="#D50000", lw=2)
    ax.set_xlabel("Frequency (GHz)")
    ax.set_ylabel("Q")
    ax.set_title("Quality factor")
    ax.grid(True, alpha=0.3)
    if summary.get("f_at_Qmax_hz"):
        ax.axvline(summary["f_at_Qmax_hz"] / 1e9, color="#00C853", ls="--", lw=1, label="Qmax")
        ax.legend(loc="best", fontsize=8)

    ax = axs[1, 0]
    ax.plot(f_g, 20 * np.log10(np.maximum(np.abs(s11), 1e-12)), color="#1565C0", lw=2, label="|S11|")
    ax.plot(f_g, 20 * np.log10(np.maximum(np.abs(s21), 1e-12)), color="#E63900", lw=2, label="|S21|")
    ax.set_xlabel("Frequency (GHz)")
    ax.set_ylabel("Magnitude (dB)")
    ax.set_title("S-parameters")
    ax.grid(True, alpha=0.3)
    ax.legend(loc="best", fontsize=8)

    ax = axs[1, 1]
    ax.axis("off")
    lines = [
        f"Engine: {summary.get('engine', 'n/a')}",
        f"L₀ = {summary.get('L0_nH', float('nan')):.3f} nH",
        f"L @ f_ref = {summary.get('L_at_fref_nH', float('nan')):.3f} nH",
        f"Q @ f_ref = {summary.get('Q_at_fref', float('nan')):.1f}",
        f"Q_max = {summary.get('Q_max', float('nan')):.1f}",
        f"f @ Q_max = {summary.get('f_at_Qmax_hz', 0)/1e9:.2f} GHz",
        f"C_ox ≈ {summary.get('C_fF', float('nan')):.1f} fF",
        f"SRF_est ≈ {summary.get('SRF_est_GHz') or float('nan'):.1f} GHz",
        f"segments = {summary.get('n_segments', '?')}",
        f"length = {summary.get('length_um', float('nan')):.1f} µm",
    ]
    ax.text(
        0.05,
        0.95,
        "\n".join(lines),
        transform=ax.transAxes,
        va="top",
        family="monospace",
        fontsize=10,
        bbox=dict(boxstyle="round", facecolor="#F5F5F5", edgecolor="#BDBDBD"),
    )
    ax.set_title("Summary")

    out = sim / "performance.png"
    fig.savefig(out, dpi=140)
    plt.close(fig)
    print(f"Wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
