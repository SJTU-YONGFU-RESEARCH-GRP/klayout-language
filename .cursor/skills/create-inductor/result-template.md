# RESULT — inductor/<N> — \<name\>

## Summary

| Field | Value |
|-------|-------|
| Run | `inductor/<N>` |
| Name | |
| Shape | |
| Ports / role | |
| Layers | |
| Width / space | µm / µm |
| Turns | |
| DRC | PASS / FAIL / SKIPPED |
| LVS | PASS / FAIL / SKIPPED |
| SHORTS | PASS / FAIL / SKIPPED |
| openEMS | OK / SKIPPED |

One-line verdict: …

## Layout screenshot

![inductor layout](layout/inductor.png)

**Layer colors:** M1 **blue** · M2 **red** · VIA **yellow** · M1 labels **green** · M2 labels **magenta**

Generate with: `./inductor/common/run_screenshot.sh inductor/<N>`

## Config

```yaml
# paste key fields from config.yaml
```

## DRC

- Command: `./inductor/common/run_drc.sh inductor/<N>`
- Violations: 0
- Log: `drc/…`

## LVS

- Command: `./inductor/common/run_lvs.sh inductor/<N>`
- Result: PASS / FAIL
- Log: `lvs/…`

## EM (openEMS)

| Metric | Value |
|--------|-------|
| L @ f_ref | nH |
| Q_max | |
| f @ Q_max | GHz |
| Notable S-params | |

- Data: `sim/sparams.csv`, `sim/lq.csv`
- Plots: `sim/…` (if any)

## Files

- `layout/inductor.gds`
- `config.yaml`

## Next steps

- …
