# Save Layout Screenshot (KLayout plugin)

Python macro that adds a **Screenshot** menu tab with **Save Layout Screenshot** (`Ctrl+Shift+S`) so you can export the current layout view as a PNG.

## Features

| Mode | API | Behavior |
|------|-----|----------|
| Viewport screenshot | `LayoutView.save_screenshot` | Same pixel size as the current view |
| Custom resolution | `LayoutView.save_image` | Redraw at width × height (e.g. 1920×1080) |

Default save directory: `<repo>/screenshots` (set at deploy time). Override with `KLAYOUT_SCREENSHOT_DIR`.

## Install

```bash
./deploy.sh              # install into auto-detected KLayout pymacros
./deploy.sh --dry-run    # show what would happen
./deploy.sh --uninstall  # remove
```

Override destination if needed:

```bash
./deploy.sh --dest "$HOME/.klayout/pymacros"
```

Installs both files:

| File | Destination |
|------|-------------|
| `save_screenshot.lym` | `$KLAYOUT_HOME/pymacros/` |
| `save_screenshot.py` | `$KLAYOUT_HOME/python/` |

`KLAYOUT_HOME` is respected when set (default Linux: `~/.klayout`).

Restart KLayout (or **Macros → Macro Development → reload**).

## Usage

1. Open a layout.
2. **Screenshot → Save Layout Screenshot** (or `Ctrl+Shift+S`).
3. Choose viewport vs custom resolution, pick a path, click OK.

## Notes

- Output is always **PNG**.
- Viewport mode needs the view to finish drawing; if the image looks blank, wait a moment and retry, or use custom resolution mode.
- For batch / headless export without the GUI, use a standalone `LayoutView` and `save_image` / `save_image_with_options` instead of this menu macro.
