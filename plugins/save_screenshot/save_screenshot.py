# Save Layout Screenshot / Image for KLayout
# Menu: Screenshot → Save Layout Screenshot

import os
from datetime import datetime

import pya

MENU_NAME = "screenshot_menu"
MENU_TITLE = "Screenshot"
ACTION_NAME = "save_layout_screenshot"
ACTION_TITLE = "Save Layout Screenshot"
ACTION_SHORTCUT = "Ctrl+Shift+S"

# Keep a reference so the Action is not garbage-collected.
_action = None


def _default_save_dir():
    """Prefer env, then deploy-time config, then <repo>/screenshots."""
    env = os.environ.get("KLAYOUT_SCREENSHOT_DIR")
    if env:
        return os.path.expanduser(env)

    try:
        from save_screenshot_config import DEFAULT_SAVE_DIR

        if DEFAULT_SAVE_DIR:
            return DEFAULT_SAVE_DIR
    except ImportError:
        pass

    here = os.path.dirname(os.path.abspath(__file__))
    # In-tree: plugins/save_screenshot/save_screenshot.py -> repo/screenshots
    if os.path.basename(here) == "save_screenshot" and os.path.basename(
        os.path.dirname(here)
    ) == "plugins":
        return os.path.join(os.path.dirname(os.path.dirname(here)), "screenshots")

    return os.path.expanduser("~/proj/klayout-language/screenshots")


def _current_view():
    mw = pya.Application.instance().main_window()
    lv = mw.current_view()
    if lv is None:
        pya.MessageBox.warning(
            "Save Screenshot",
            "No layout view is open.",
            pya.MessageBox.Ok,
        )
    return lv


def _default_path(suffix="screenshot"):
    mw = pya.Application.instance().main_window()
    lv = mw.current_view()
    base = "layout"
    if lv is not None and lv.active_cellview().is_valid():
        path = lv.active_cellview().filename()
        if path:
            base = os.path.splitext(os.path.basename(path))[0]
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = _default_save_dir()
    if not os.path.isdir(out_dir):
        os.makedirs(out_dir)
    return os.path.join(out_dir, "{}_{}_{}.png".format(base, suffix, stamp))


def _ask_save_path(title, default_path):
    path = pya.FileDialog.ask_save_file_name(
        title, default_path, "PNG image (*.png)"
    )
    if not path:
        return None
    if not path.lower().endswith(".png"):
        path += ".png"
    return path


class SaveImageDialog(pya.QDialog):
    """Dialog: choose viewport screenshot vs custom-resolution render."""

    def __init__(self, parent=None):
        super(SaveImageDialog, self).__init__(parent)
        self.setWindowTitle("Save Layout Screenshot")
        self.resize(420, 220)

        layout = pya.QVBoxLayout(self)

        self.mode_viewport = pya.QRadioButton(
            "Viewport screenshot (exact window size)", self
        )
        self.mode_render = pya.QRadioButton("Render at custom resolution", self)
        self.mode_viewport.setChecked(True)

        layout.addWidget(self.mode_viewport)
        layout.addWidget(self.mode_render)

        form = pya.QFormLayout()
        self.width_edit = pya.QLineEdit("1920", self)
        self.height_edit = pya.QLineEdit("1080", self)
        form.addRow("Width (px):", self.width_edit)
        form.addRow("Height (px):", self.height_edit)
        layout.addLayout(form)

        self.path_edit = pya.QLineEdit(_default_path(), self)
        browse = pya.QPushButton("Browse...", self)
        browse.clicked(self._browse)

        path_row = pya.QHBoxLayout()
        path_row.addWidget(self.path_edit)
        path_row.addWidget(browse)
        layout.addLayout(path_row)

        buttons = pya.QDialogButtonBox(
            pya.QDialogButtonBox.Ok | pya.QDialogButtonBox.Cancel, self
        )
        buttons.accepted(self.accept)
        buttons.rejected(self.reject)
        layout.addWidget(buttons)

        self.mode_viewport.toggled(self._update_enabled)
        self._update_enabled()

    def _update_enabled(self, *_args):
        custom = self.mode_render.isChecked()
        self.width_edit.setEnabled(custom)
        self.height_edit.setEnabled(custom)

    def _browse(self):
        path = _ask_save_path("Save PNG", self.path_edit.text)
        if path:
            self.path_edit.setText(path)

    def options(self):
        path = self.path_edit.text.strip()
        if not path:
            return None
        if not path.lower().endswith(".png"):
            path += ".png"
        if self.mode_viewport.isChecked():
            return {"mode": "viewport", "path": path}
        try:
            w = int(self.width_edit.text.strip())
            h = int(self.height_edit.text.strip())
        except ValueError:
            pya.MessageBox.warning(
                "Save Screenshot",
                "Width and height must be integers.",
                pya.MessageBox.Ok,
            )
            return None
        if not (w > 0 and h > 0):
            pya.MessageBox.warning(
                "Save Screenshot",
                "Width and height must be positive.",
                pya.MessageBox.Ok,
            )
            return None
        return {"mode": "render", "path": path, "width": w, "height": h}


def save_layout_screenshot():
    lv = _current_view()
    if lv is None:
        return

    dlg = SaveImageDialog(pya.Application.instance().main_window())
    if not dlg.exec_():
        return

    opts = dlg.options()
    if opts is None:
        return

    path = opts["path"]
    try:
        parent = os.path.dirname(path)
        if parent and not os.path.isdir(parent):
            os.makedirs(parent)

        if opts["mode"] == "viewport":
            lv.save_screenshot(path)
        else:
            lv.save_image(path, opts["width"], opts["height"])

        pya.MessageBox.info(
            "Save Screenshot",
            "Saved:\n{}".format(path),
            pya.MessageBox.Ok,
        )
    except Exception as e:
        pya.MessageBox.critical(
            "Save Screenshot",
            "Failed to save image:\n{}".format(e),
            pya.MessageBox.Ok,
        )


def register_menu():
    """Create the Screenshot top-level menu and bind the save action."""
    global _action

    mw = pya.Application.instance().main_window()
    menu = mw.menu()

    if not menu.is_valid(MENU_NAME):
        # Insert before Help so it appears as its own menu tab.
        menu.insert_menu("help_menu+", MENU_NAME, MENU_TITLE)

    action_path = "{}.{}".format(MENU_NAME, ACTION_NAME)
    if menu.is_valid(action_path):
        menu.delete(action_path)

    _action = pya.Action()
    _action.title = ACTION_TITLE
    _action.shortcut = ACTION_SHORTCUT
    _action.on_triggered = save_layout_screenshot
    menu.insert_item(MENU_NAME + ".end", ACTION_NAME, _action)
