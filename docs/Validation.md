<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Purpose](#purpose)
- [Documentation-Only Change Checklist](#documentation-only-change-checklist)
- [Runtime Change Checklist](#runtime-change-checklist)
- [Link and Navigation Checks](#link-and-navigation-checks)
- [GitHub Wiki Sync](#github-wiki-sync)
- [Code-vs-Documentation Audit](#code-vs-documentation-audit)
- [Manual In-Game Checklist](#manual-in-game-checklist)
- [Reporting Template](#reporting-template)

</details>

## [Purpose][Top]

Use this page before handing off changes. It separates documentation-only checks
from runtime checks and gives agents a repeatable way to report what was
validated.

## [Documentation-Only Change Checklist][Top]

For docs, examples, `AGENTS.md`, or `SKILL.md` changes:

1. Confirm no runtime files were changed unless the task explicitly allowed it.
2. Update `docs/_Sidebar.md` and folder `_Sidebar.md` files when adding,
   renaming, or moving pages.
3. Update `README.md` and `docs/Home.md` when adding important pages.
4. Keep examples generic unless documenting a host-addon wrapper pattern.
5. Prefer stable ids and realistic field names in every code snippet.
6. Avoid introducing undocumented API names in examples.
7. Make every example explain when to use it and what value shape it stores.
8. Check Markdown tables render cleanly.
9. Check headings match the table of contents anchors.
10. Keep `SKILL.md` operational: it should tell an AI what to read, what to
    change, what not to change, and how to validate.

## [Runtime Change Checklist][Top]

For allowed code changes in this repository, run focused syntax checks from the
repository root:

```bash
lua -e 'assert(loadfile("runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua")); assert(loadfile("runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua"))'
```

When runtime code adds or changes `L["..."]` strings, verify every key exists
in every built-in locale:

```bash
python3 - <<'PY'
from pathlib import Path
import re
texts = '\n'.join(p.read_text() for p in Path('runtime/LibSettingsDesigner').glob('*.lua'))
used = set(re.findall(r'L\["([^"]+)"\]', texts))
ui = Path('runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua').read_text()
failed = False
locales = re.findall(r'\n\t([a-z][a-z][A-Z][A-Z]) = \{', ui)
for locale in locales:
    start = ui.index(f'\n\t{locale} = {{')
    match = re.search(r'\n\t[a-z][a-z][A-Z][A-Z] = \{|\n}\n', ui[start + 1:])
    end = start + 1 + match.start() if match else len(ui)
    keys = set(re.findall(r'\n\t\t([A-Za-z0-9_]+) = ', ui[start:end]))
    missing = sorted(used - keys)
    if missing:
        failed = True
        print(f'{locale} missing: {", ".join(missing)}')
if failed:
    raise SystemExit(1)
print(f'ok locales={len(locales)} keys={len(used)}')
PY
```

When validating a host addon that vendors the library, run the same check
against that addon's local copy:

```bash
lua -e 'assert(loadfile("libs/LibSettingsDesigner/LibSettingsDesignerConfig.lua")); assert(loadfile("libs/LibSettingsDesigner/LibSettingsDesignerUI.lua"))'
```

Run the host addon's configured lint/test command when available. If library
files are intentionally excluded from lint, say so in the final report and show
the syntax-check result instead.

Run Luacheck before merging any pull request that touches runtime Lua, sample
addon Lua, Lua config, or packaging-relevant Lua files:

```bash
luacheck runtime/LibSettingsDesigner Samples/LibSettingsDesignerSample
```

Fix real warnings before merge. Expected World of Warcraft globals or sample
SavedVariables belong in `.luacheckrc`; do not hide warnings with broad inline
suppression unless the warning is intentionally local to one line.

## [Link and Navigation Checks][Top]

Useful local checks:

```bash
rg -n '\[[^]]+\]\([^)]*\)' README.md AGENTS.md SKILL.md docs
rg -n 'TO[D]O|TB[D]|FIXM[E]' README.md AGENTS.md SKILL.md docs
```

Manual checks:

- `docs/_Sidebar.md` links to high-level pages.
- `docs/API/_Sidebar.md` links back to Home, Vendoring, Quick Start, Elements, and
  Examples.
- `docs/Elements/_Sidebar.md` links to every element page.
- `docs/Examples/_Sidebar.md` links to every example page.
- New pages are discoverable from at least `docs/Home.md` or `README.md`.

## [GitHub Wiki Sync][Top]

The public wiki at
`https://github.com/R41z0r/LibSettingsDesigner/wiki` is backed by a separate Git
repository:

```bash
git clone https://github.com/R41z0r/LibSettingsDesigner.wiki.git
```

`docs/` remains the source copy for review and pull requests. After a
documentation pull request is merged to `main`, `.github/workflows/sync-wiki.yml`
syncs the wiki repository automatically.

If the workflow is unavailable, run the same sync locally:

```bash
git clone https://github.com/R41z0r/LibSettingsDesigner.wiki.git
python3 scripts/sync_wiki_docs.py docs LibSettingsDesigner.wiki
```

Do not treat the wiki as a normal subfolder of this repository. The wiki uses a
flat page layout:

```text
docs/Elements/Toggle.md  -> Toggle.md
docs/API/Config-API.md   -> Config-API.md
docs/Examples/Support-Links.md -> Support-Links.md
docs/assets/images/*.png -> assets/images/*.png
```

Rewrite internal links during sync:

- `Elements/Toggle.md` -> `Toggle`
- `../Elements/Toggle.md` -> `Toggle`
- `Examples/Support-Links.md` -> `Support-Links`
- `../assets/images/example.png` -> `assets/images/example.png`

Do not add the wiki as a submodule or subtree unless the owner explicitly asks
for that repository-structure change. Keeping it separate avoids packaging or
vendoring the public wiki with the runtime library.

## [Code-vs-Documentation Audit][Top]

When source files are available, use this process to keep docs matched to code:

1. Inspect exported namespaces in
   `runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua` and
   `runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua`.
2. List public Config methods and compare them with `docs/API/Config-API.md`.
3. List public UI methods and compare them with `docs/API/UI-API.md`.
4. Search for supported control `type` values and compare them with
   `docs/Elements/Elements.md`.
5. For every changed control type, update its element page with fields,
   callbacks, value shape, and at least one example.
6. Search for field aliases in code and compare them with
   `docs/Field-Glossary.md`.
7. Search for old names and verify docs do not recommend them.
8. Run examples mentally against the documented read/write/default order.
9. Report any docs that could not be verified because source files were not
   available.

Useful commands when source files exist:

```bash
rg -n 'function .*Register|Register[A-Za-z]+\s*=|\.Register[A-Za-z]+' runtime/LibSettingsDesigner
rg -n 'type\s*==\s*"|control\.type|data\.type' runtime/LibSettingsDesigner
rg -n 'getValue|setValue|getSelection|setSelection|parentCheck|visibleWhen|hiddenWhen' runtime/LibSettingsDesigner
```

## [Manual In-Game Checklist][Top]

1. `/reload`
2. Open the settings center.
3. Verify the dashboard, sidebar, search field, and close button.
4. Open a category page list and a page detail view.
5. Test each touched control type.
6. Verify disabled rows do not show active hover/interaction states.
7. Verify hidden rows/pages are actually absent.
8. Test search by label, id, keyword alias, and note text.
9. Test reset on one control and one page.
10. Test direct navigation: `ConfigUI:Open(app, pageID, controlID)`.
11. Test compact/comfortable density when enabled.
12. Check BugSack or the default Lua error frame.

## [Reporting Template][Top]

Use this format in final handoff notes:

```text
Changed:
- Docs: ...
- Skill/agent instructions: ...
- Runtime code: none / list files

Validated:
- Markdown/navigation: ...
- Source/API match: verified against code / not possible because source files were absent
- Syntax/lint: ...
- In-game: done / not run

Remaining recommendations:
- ...
```

[//]: # (Links)
[Top]: #Top
