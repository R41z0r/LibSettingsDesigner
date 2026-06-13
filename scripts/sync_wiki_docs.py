#!/usr/bin/env python3
"""Sync repository docs into a flat GitHub wiki checkout."""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path


def rewrite_links(text: str) -> str:
    text = re.sub(r"\((?:\.\./)?(?:API|Elements|Examples)/([^/)#]+)\.md(#[^)\s\"]+)?", r"(\1\2", text)
    text = re.sub(r"\((?:\.\./)?([^/)#]+)\.md(#[^)\s\"]+)?", r"(\1\2", text)
    text = text.replace("(../assets/images/", "(assets/images/")
    text = text.replace("](../", "](")
    return text


def sync_docs(source: Path, target: Path) -> None:
    source = source.resolve()
    target = target.resolve()
    if not source.is_dir():
        raise SystemExit(f"docs source not found: {source}")
    if not target.is_dir():
        raise SystemExit(f"wiki target not found: {target}")

    for markdown in source.rglob("*.md"):
        relative = markdown.relative_to(source)
        if relative.name == "_Sidebar.md" and len(relative.parts) > 1:
            continue
        (target / relative.name).write_text(rewrite_links(markdown.read_text()), encoding="utf-8")

    assets = source / "assets"
    if assets.exists():
        shutil.copytree(assets, target / "assets", dirs_exist_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", help="repository docs directory")
    parser.add_argument("target", help="checked out GitHub wiki directory")
    args = parser.parse_args()
    sync_docs(Path(args.source), Path(args.target))


if __name__ == "__main__":
    main()
