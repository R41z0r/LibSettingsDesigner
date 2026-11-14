# Validation and docs

Read only the sections relevant to the requested change. Paths in code examples
are relative to the library or host checkout as indicated. `docs/` paths refer
to the skill root documentation. This reference does not authorize external
actions or reading repository instructions outside the active project.

## Documentation Rules

When changing docs:

- Keep `README.md` as an entry point, not the only documentation surface.
- Add/update `docs/Elements/*.md` for element behavior.
- Add/update `docs/Examples/*.md` for reusable workflows.
- Update `docs/Field-Glossary.md` when fields or aliases change.
- Update `docs/Troubleshooting.md` when a repeated failure mode is found.
- Update `docs/Validation.md` when checks or handoff expectations change.
- Update `docs/_Sidebar.md` and folder `_Sidebar.md` files when adding pages.
- Keep examples generic unless documenting a host-addon wrapper pattern.
- Use stable ids and realistic DB shapes in snippets.
- Do not document API fields that cannot be found in code when source is
  available.

## Validation

For documentation-only tasks, run these scans from this skill root. They
cover skill references as well as public docs. Include the active project's
`AGENTS.md` only when this is that project; never scan an external project's
`AGENTS.md` merely because its shared skill is being used. When validating a
host-only change, scope checks to the touched host documentation instead.

```bash
rg -n 'TO[D]O|TB[D]|FIXM[E]' README.md SKILL.md docs references
rg -n '\[[^]]+\]\([^)]*\)' README.md SKILL.md docs references
```

For runtime code tasks when source files are present:

```bash
lua -e 'assert(loadfile("runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua")); assert(loadfile("runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua"))'
luacheck runtime/LibSettingsDesigner Samples/LibSettingsDesignerSample
```

When `runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua` or
`runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua` changes, synchronize the
matching files under
`Samples/LibSettingsDesignerSample/libs/LibSettingsDesigner/` before final
validation. The sample addon's vendored copy should match the source runtime
unless a task explicitly asks to test a divergent vendored snapshot.

When validating a host addon that vendors the library, check that addon's local
copy instead:

```bash
lua -e 'assert(loadfile("libs/LibSettingsDesigner/LibSettingsDesignerConfig.lua")); assert(loadfile("libs/LibSettingsDesigner/LibSettingsDesignerUI.lua"))'
```

If the host addon has Luacheck or tests for the touched files, run them. If the
library files are intentionally excluded from lint, say so and report the syntax
check instead.

For docs/skill/runtime alignment:

- Compare documented app methods against `function AppMixin:` in
  `LibSettingsDesignerConfig.lua`.
- Compare documented UI methods against public functions in
  `LibSettingsDesignerUI.lua`.
- Fail docs review if docs/skill mention public APIs not present in runtime,
  such as `ResetControl`, `ResetPage`, or `Search`.
- Check that sample vendored runtime matches source runtime.
- Check LibSettingsDesigner is not registered through LibStub.
- Check locale key parity across `lib.LOCALES`.
- Check runtime Lua/XML files retain the license notice.
- Check `LibSettingsDesigner.xml` loads Config before UI.

## Common Mistakes

- Reintroducing shared LibStub registration for this library.
- Adding addon-specific feature logic to `LibSettingsDesignerUI.lua`.
- Adding feature strings to the generic library instead of the host addon locale.
- Using display text as ids.
- Using `key = "nested.path"` in direct LibSettingsDesigner code without wrapper
  support.
- Forgetting defaults, causing reset/customized state to be unreliable.
- Storing booleans as strings.
- Omitting `orderList` for user-facing dropdowns.
- Rebuilding UI from a MultiDropdown selection callback.
- Forgetting to update `docs/_Sidebar.md` and folder `_Sidebar.md` files when adding docs pages.
- Claiming code-level verification when source files were not available.

## Handoff Format

End with:

```text
Changed:
- ...

Validated:
- ...

Not verified / limitations:
- ...

Recommended next steps:
- ...
```
