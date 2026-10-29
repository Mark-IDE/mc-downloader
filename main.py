#!/usr/bin/env python3
"""MC 下载器入口。

默认打开图形界面；带子命令（list / install / apk / launcher / selftest）时走命令行。
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

CLI_COMMANDS = {"list", "install", "loader", "mod", "apk", "launcher", "selftest"}


def main(argv=None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if argv and argv[0] == "--gui":
        return run_gui()
    if argv and (argv[0] in CLI_COMMANDS or argv[0].startswith("-")):
        from mc_downloader.cli import run_cli

        return run_cli(argv)
    return run_gui()


def run_gui() -> int:
    from mc_downloader.config import Config
    from mc_downloader.ui.app import App

    cfg = Config()
    app = App(cfg)
    app.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
