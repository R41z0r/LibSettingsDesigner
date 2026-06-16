#!/usr/bin/env python3
"""Update the sample addon's TOC metadata."""

from __future__ import annotations

import argparse
import pathlib
import re
import sys
import urllib.request


DEFAULT_TOC_PATH = pathlib.Path("Samples/LibSettingsDesignerSample/LibSettingsDesignerSample.toc")
DEFAULT_CHANGELOG_PATH = pathlib.Path("Samples/LibSettingsDesignerSample/CHANGELOG.md")
DEFAULT_VERSION_SOURCES = {
    "retail": "https://raw.githubusercontent.com/Gethe/wow-ui-source/live/version.txt",
    "classic": "https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_era/version.txt",
    "bcc": "https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_anniversary/version.txt",
    "mists": "https://raw.githubusercontent.com/Gethe/wow-ui-source/classic/version.txt",
    "titan": "https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_titan/version.txt",
}
DISPLAY_NAMES = {
    "retail": "Retail",
    "classic": "Classic Era",
    "bcc": "Burning Crusade Classic",
    "wrath": "Wrath Classic",
    "cata": "Cataclysm Classic",
    "mists": "Mists Classic",
    "titan": "Titan Classic",
}
CHANGELOG_ENTRY = "- Kept all supported Retail and Classic Interface versions in the main TOC Interface list."


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


def parse_version_source(value: str) -> tuple[str, str]:
    if "=" not in value:
        raise argparse.ArgumentTypeError("version sources must use the form game_type=url")

    game_type, url = value.split("=", 1)
    game_type = game_type.strip().lower()
    url = url.strip()

    known_game_types = set(DEFAULT_VERSION_SOURCES) | {"wrath", "cata"}
    if game_type not in known_game_types:
        known = ", ".join(sorted(known_game_types))
        raise argparse.ArgumentTypeError(f"unknown game type {game_type!r}; expected one of: {known}")
    if not url:
        raise argparse.ArgumentTypeError("version source URL must not be empty")

    return game_type, url


def update_toc_interface(toc_path: pathlib.Path, interface_version: int) -> bool:
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


def remove_flavor_interface_lines(toc_path: pathlib.Path) -> bool:
    text = toc_path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    kept_lines = [line for line in lines if not re.match(r"^## Interface-[A-Za-z]+:", line)]
    if kept_lines == lines:
        return False

    toc_path.write_text("".join(kept_lines), encoding="utf-8")
    return True


def update_toc_version(toc_path: pathlib.Path, addon_version: str) -> bool:
    addon_version = addon_version.strip()
    if not addon_version:
        raise ValueError("Addon version must not be empty")

    text = toc_path.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)

    for index, line in enumerate(lines):
        match = re.match(r"^(## Version:\s*)(.*?)(\r?\n)?$", line)
        if not match:
            continue

        prefix, current_version, newline = match.groups()
        if current_version == addon_version:
            return False

        lines[index] = f"{prefix}{addon_version}{newline or ''}"
        toc_path.write_text("".join(lines), encoding="utf-8")
        return True

    raise ValueError(f"No '## Version:' line found in {toc_path}")


def update_changelog(changelog_path: pathlib.Path) -> bool:
    text = changelog_path.read_text(encoding="utf-8")
    if CHANGELOG_ENTRY in text:
        return False

    marker = "## Unreleased"
    marker_index = text.find(marker)
    if marker_index == -1:
        raise ValueError(f"No '## Unreleased' section found in {changelog_path}")

    insert_at = text.find("\n", marker_index)
    if insert_at == -1:
        new_text = f"{text}\n\n{CHANGELOG_ENTRY}\n"
    else:
        insert_at += 1
        if insert_at < len(text) and text[insert_at] != "\n":
            new_text = f"{text[:insert_at]}\n{CHANGELOG_ENTRY}\n{text[insert_at:]}"
        else:
            new_text = f"{text[:insert_at]}{CHANGELOG_ENTRY}\n{text[insert_at:]}"

    changelog_path.write_text(new_text, encoding="utf-8")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--toc", type=pathlib.Path, default=DEFAULT_TOC_PATH)
    parser.add_argument(
        "--version-url",
        help="Deprecated alias for the Retail version source.",
    )
    parser.add_argument(
        "--version-source",
        action="append",
        type=parse_version_source,
        help="Version source in the form game_type=url. May be passed multiple times.",
    )
    parser.add_argument(
        "--version-text",
        help="Use literal Retail version text instead of fetching from --version-url. Useful for tests.",
    )
    parser.add_argument(
        "--addon-version",
        help="Set the sample addon's ## Version metadata to this value.",
    )
    parser.add_argument(
        "--skip-interface",
        action="store_true",
        help="Skip updating ## Interface metadata.",
    )
    parser.add_argument(
        "--changelog",
        type=pathlib.Path,
        help="Add a short Unreleased changelog entry when Interface metadata changes.",
    )
    args = parser.parse_args()

    changed = False
    interface_changed = False

    if not args.skip_interface:
        removed_flavor_lines = remove_flavor_interface_lines(args.toc)
        changed = changed or removed_flavor_lines
        interface_changed = interface_changed or removed_flavor_lines
        if removed_flavor_lines:
            print(f"Removed flavor-specific Interface metadata from {args.toc}")

        if args.version_text is not None:
            version_sources = {"retail": args.version_text}
            source_is_literal = True
        elif args.version_source:
            version_sources = dict(args.version_source)
            source_is_literal = False
        elif args.version_url:
            version_sources = {"retail": args.version_url}
            source_is_literal = False
        else:
            version_sources = DEFAULT_VERSION_SOURCES
            source_is_literal = False

        for game_type, source in version_sources.items():
            version_text = source if source_is_literal else fetch_text(source)
            interface_version = parse_interface(version_text)
            game_changed = update_toc_interface(args.toc, interface_version)
            changed = changed or game_changed
            interface_changed = interface_changed or game_changed
            display_name = DISPLAY_NAMES[game_type]

            if game_changed:
                print(f"Added Interface {interface_version} for {display_name} to {args.toc}")
            else:
                print(f"Interface {interface_version} for {display_name} already present in {args.toc}")

        if args.changelog and interface_changed:
            changelog_changed = update_changelog(args.changelog)
            changed = changed or changelog_changed
            if changelog_changed:
                print(f"Added Interface metadata changelog entry to {args.changelog}")
            else:
                print(f"Interface metadata changelog entry already present in {args.changelog}")

    if args.addon_version is not None:
        version_changed = update_toc_version(args.toc, args.addon_version)
        changed = changed or version_changed

        if version_changed:
            print(f"Set Version {args.addon_version} in {args.toc}")
        else:
            print(f"Version {args.addon_version} already present in {args.toc}")

    if args.skip_interface and args.addon_version is None:
        parser.error("--skip-interface requires --addon-version")

    return 0


if __name__ == "__main__":
    sys.exit(main())
