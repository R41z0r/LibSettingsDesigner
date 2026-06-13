#!/usr/bin/env python3
"""Update the sample addon's Retail Interface metadata from wow-ui-source."""

from __future__ import annotations

import argparse
import pathlib
import re
import sys
import urllib.request


DEFAULT_VERSION_URL = "https://raw.githubusercontent.com/Gethe/wow-ui-source/live/version.txt"
DEFAULT_TOC_PATH = pathlib.Path("Samples/LibSettingsDesignerSample/LibSettingsDesignerSample.toc")


def parse_interface(version_text: str) -> int:
    first_line = version_text.strip().splitlines()[0].strip()
    match = re.match(r"^(\d+)\.(\d+)\.(\d+)(?:\.|$)", first_line)
    if not match:
        raise ValueError(f"Could not parse WoW version from {first_line!r}")

    major, minor, patch = (int(part) for part in match.groups())
    return major * 10000 + minor * 100 + patch


def fetch_text(url: str) -> str:
    request = urllib.request.Request(
        url,
        headers={"User-Agent": "LibSettingsDesigner TOC updater"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def update_toc(toc_path: pathlib.Path, interface_version: int) -> bool:
    text = toc_path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)

    for index, line in enumerate(lines):
        match = re.match(r"^(## Interface:\s*)(.*?)(\r?\n)?$", line)
        if not match:
            continue

        prefix, value_text, newline = match.groups()
        values = [int(value) for value in re.findall(r"\d+", value_text)]
        if interface_version in values:
            return False

        values.append(interface_version)
        values = sorted(set(values))
        lines[index] = f"{prefix}{', '.join(str(value) for value in values)}{newline or ''}"
        toc_path.write_text("".join(lines), encoding="utf-8")
        return True

    raise ValueError(f"No '## Interface:' line found in {toc_path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--toc", type=pathlib.Path, default=DEFAULT_TOC_PATH)
    parser.add_argument("--version-url", default=DEFAULT_VERSION_URL)
    parser.add_argument(
        "--version-text",
        help="Use literal version text instead of fetching from --version-url. Useful for tests.",
    )
    args = parser.parse_args()

    version_text = args.version_text if args.version_text is not None else fetch_text(args.version_url)
    interface_version = parse_interface(version_text)
    changed = update_toc(args.toc, interface_version)

    if changed:
        print(f"Added Interface {interface_version} to {args.toc}")
    else:
        print(f"Interface {interface_version} already present in {args.toc}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
