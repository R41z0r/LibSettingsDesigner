# LibSettingsDesigner Agent Instructions

These instructions apply to work inside this folder and to vendored copies of
LibSettingsDesigner in host addons.

Use them as the operating contract for human and AI contributors. The goal is
simple: a contributor should be able to add, review, document, or integrate a
settings page without guessing how the library is supposed to work.

## Mission

LibSettingsDesigner is a generic, vendored World of Warcraft addon settings
center. It turns structured metadata into a rendered settings UI.

It must remain:

- vendored per host addon
- independent from any specific addon brand or feature set
- documented with realistic examples
- safe for wrapper-based host addon integrations
- easy for an AI agent to inspect, modify, and validate

## Non-Negotiable Contracts

- Do not register LibSettingsDesigner through `LibStub:NewLibrary`.
- Do not depend on another addon's copy of LibSettingsDesigner.
- Do not put host-addon feature logic into the generic library runtime files.
- Do not put host-addon feature strings into the generic library runtime files.
- Do not rebuild the settings frame from dropdown or MultiDropdown option-click
  callbacks.
- Do not change runtime code during documentation-only tasks.
- Keep `frame._LibSettingsDesignerState` as the documented internal frame-state
  field.
- Do not remove LibSettingsDesigner license notices from runtime Lua/XML files
  or vendored runtime copies.
- New runtime Lua/XML files must include the LibSettingsDesigner license notice:

```text
LibSettingsDesigner
License: https://raw.githubusercontent.com/R41z0r/LibSettingsDesigner/main/LICENSE.md
Do not remove this notice from redistributed copies.
```

## Branch and Release Policy

- `main` is the latest-stable branch and must always be releasable.
- Never commit directly to `main`.
- All changes must be made on a feature branch and merged through a pull
  request.
- Pull requests must pass validation before merge.
- Pull requests that change runtime Lua/XML/assets or sample addon Lua/XML/assets
  must not be merged to `main` until the changed behavior was tested in game and
  the user confirmed that it works.
- Sample addon TOC-only metadata updates, such as adding a new `## Interface`
  version, may be opened and merged automatically by the scheduled workflow.
- Documentation-only pull requests do not require an in-game test, but must
  still keep documentation validation clean.
- Host addons may use BigWigsPackager with `branch: main` only because `main` is
  protected by this policy.
- Use version tags such as `v1` for fully reproducible host-addon releases.

Current namespace:

```lua
addon.LibSettingsDesigner.Config
addon.LibSettingsDesigner.UI
```

Current runtime file names:

```text
LibSettingsDesigner.xml
LibSettingsDesignerConfig.lua
LibSettingsDesignerUI.lua
Assets/
```

## Expected Layout

Repository layout:

```text
LibSettingsDesigner/
  runtime/
    LibSettingsDesigner/
      LibSettingsDesigner.xml
      LibSettingsDesignerConfig.lua
      LibSettingsDesignerUI.lua
      Assets/
  docs/
    Home.md
    Architecture.md
    Vendoring.md
    Quick-Start.md
    Field-Glossary.md
    Troubleshooting.md
    Validation.md
    API/
    Elements/
    Examples/
    _Sidebar.md
  AGENTS.md
  SKILL.md
  README.md
```

Runtime layout inside a host addon:

```text
MyAddon/
  MyAddon.toc
  libs/
    LibSettingsDesigner/
      LibSettingsDesigner.xml
      LibSettingsDesignerConfig.lua
      LibSettingsDesignerUI.lua
      Assets/
```

## Source of Truth Order

When code is available, treat the runtime source as the highest source of truth.
Then update docs to match it.

Use this priority:

1. `runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua`
2. `runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua`
3. Host addon wrapper helpers, if the task is wrapper-related
4. `docs/API/*.md`
5. `docs/Elements/*.md`
6. `docs/Examples/*.md`
7. `README.md`, `docs/Home.md`, sidebars, `AGENTS.md`, `SKILL.md`

When source files are not available, say that code-level verification was not
possible and keep changes limited to documented behavior.

## First Steps for Any Task

1. Identify whether the task allows runtime code changes, documentation changes,
   or both.
2. Inspect the files relevant to the requested scope.
3. If the task is documentation-only, check the diff before finishing and verify
   no runtime files changed.
4. If adding or changing an element, read its page under `docs/Elements/` first.
5. If changing public APIs, read `docs/API/Config-API.md` and `docs/API/UI-API.md`.
6. If changing wrapper behavior, read `docs/Examples/Wrapper-Bridge-Pattern.md` and
   the host addon's local settings wrapper file.
7. If adding a new page, update all relevant sidebars and indexes.
8. End with a clear report: changed files, validation performed, and anything
   not verifiable.

## Runtime Architecture

The library has two public parts:

| API | Responsibility |
| :-- | :------------- |
| `addon.LibSettingsDesigner.Config` | App registry, categories, pages, groups, controls, defaults, value reads/writes, visibility, search, customized counts, legacy bridge. |
| `addon.LibSettingsDesigner.UI` | Main frame, dashboard, sidebar, page layout, widgets, notes, search, density, frame size/lock, open/toggle helpers. |

The host addon owns:

- saved variables
- localization
- feature-specific callbacks
- wrapper helpers
- runtime refresh functions
- addon-specific icons/media

## Registration Model

Use this order:

```lua
local app = Config:RegisterAddOn(addonName, opts)
app:RegisterCategory(data)
app:RegisterPage(data)
app:RegisterGroup(pageID, data)      -- optional
app:RegisterPageNote(pageID, data)   -- optional
app:RegisterControl(pageID, data)
app:RegisterControlNote(controlID, data) -- optional
```

Minimal example:

```lua
app:RegisterCategory({ id = "general", title = GENERAL or "General", order = 100 })

app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "Core",
  description = "Main addon behavior.",
  order = 100,
})

app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = ENABLE or "Enable",
  default = true,
})
```

## Control Rules

- `id` is the stable UI identity.
- `key` / `var` is for direct DB-backed values under `opts.db()`.
- `label` / `text` / `name` is user-facing text and can be localized.
- `description` / `desc` is short row help.
- `note`, `notes`, `richNote`, and `richNotes` are for longer hover help.
- `default` or `dbDefault` is required for reliable reset/customized behavior.
- `getValue` / `setValue` should be used for nested tables, private DBs,
  per-character values, derived values, and compatibility fallbacks.
- `visibleWhen` / `hiddenWhen` removes the row/page.
- `isEnabled` / `parentCheck` keeps the row visible but disabled.
- `keywords` / `searchtags` improves search discoverability.
- `newTagID` only works when the app provides `isNewTag`.

Do not use localized labels as ids. A translation change must not break saved
state, search focus, open targets, or wrapper mappings.

## Value and Default Rules

Documented default resolution order:

1. `control.default`
2. `control.dbDefault`
3. `control.setting:GetDefaultValue()` or `control.setting:GetDefault()`

Documented value read order:

1. `control.setting:GetValue()`
2. `control.getSelection(control)` or `control.getSelection()`
3. `control.getValue()`
4. `opts.db()[control.key]`
5. `control.default`

Documented value write order:

1. `control.setting:SetValue(value)`
2. `control.setSelection(selection)` for MultiDropdown map writes
3. `control.setValue(value)`
4. `opts.db()[control.key] = value`

If a control does not behave as expected, make the getter/setter explicit rather
than relying on fallback order.

## Dropdown and MultiDropdown Rules

Dropdowns:

- Use `list` / `options` for static value-to-label maps.
- Use `orderList` / `order` for deterministic ordering.
- Use `listFunc` / `optionfunc` for runtime data.
- Use `menuHeight` for large lists.

MultiDropdowns:

- Store selections as a boolean map: `selection[value] == true`.
- Deselect by removing a key or assigning `nil`.
- Keep `setSelection` and `setSelectedFunc` focused on data and lightweight
  runtime preview refresh.
- Do not rebuild the settings frame while the dropdown menu is open.

## Wrapper Bridge Rules

If a host addon has wrapper helpers such as `SettingsCreateCheckbox`, feature
modules should call those wrappers instead of raw LibSettingsDesigner APIs.

The wrapper layer may call:

```lua
app:RegisterLegacyCategory(category, data)
app:RegisterLegacySection(section, data)
app:RegisterLegacyControl(data)
```

Wrapper responsibilities:

- translate old wrapper field names to LibSettingsDesigner field names
- register legacy Blizzard settings metadata when still needed
- provide localized strings
- assign page/group/control ids
- connect defaults and runtime callbacks

Feature modules should remain small and should not need to know renderer details.

## Documentation Rules

Maintain documentation as a wiki-style reference set:

- `README.md` is the broad entry point.
- `docs/Home.md` is the wiki landing page.
- `docs/Architecture.md` explains the mental model.
- `docs/Vendoring.md` explains installation/loading.
- `docs/Quick-Start.md` gives the smallest useful setup.
- `docs/Field-Glossary.md` defines field names and aliases.
- `docs/API/*.md` documents public API methods.
- `docs/Elements/*.md` documents each rendered element.
- `docs/Examples/*.md` documents reusable workflows.
- `docs/Troubleshooting.md` documents common failures.
- `docs/Validation.md` documents checks and reporting.
- `docs/_Sidebar.md` and folder `_Sidebar.md` files must be updated when navigation changes.
- `SKILL.md` must stay usable by an AI agent.

Every new element type needs:

1. a `docs/Elements/<Element>.md` page
2. a field table
3. value shape documentation
4. at least one realistic example
5. links from `docs/Elements/Elements.md` and `docs/Elements/_Sidebar.md`
6. a mention in `docs/Field-Glossary.md`

Every reusable workflow needs:

1. a `docs/Examples/<Workflow>.md` page
2. an explanation of when to use it
3. a complete enough snippet to copy safely
4. warnings for common mistakes
5. links from `docs/Examples/Examples.md` and `docs/Examples/_Sidebar.md`

## AI Agent Workflow

For an implementation request:

1. Read `AGENTS.md` and `SKILL.md`.
2. Read the `docs/API`, `docs/Elements`, or `docs/Examples` pages for the touched area.
3. Inspect runtime source if present.
4. Make the smallest safe change that satisfies the request.
5. Update docs/examples when behavior or public fields changed.
6. Run validation checks.
7. Report exact files changed and any checks not run.

For a documentation review request:

1. Inventory docs, sidebars, examples, and skill instructions.
2. Check whether runtime code is present.
3. If code is present, compare documented APIs/fields/control types against it.
4. If code is absent, state that exact code matching cannot be proven.
5. Improve clarity, examples, navigation, and agent instructions without touching
   runtime files.
6. Package or report the result.

## Validation

Documentation-only checks:

```bash
rg -n 'TO[D]O|TB[D]|FIXM[E]' README.md AGENTS.md SKILL.md docs
rg -n '\[[^]]+\]\([^)]*\)' README.md AGENTS.md SKILL.md docs
```

Runtime syntax check when source files are present:

```bash
lua -e 'assert(loadfile("runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua")); assert(loadfile("runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua"))'
```

When validating a host addon that vendors the library, use that addon's local
copy instead:

```bash
lua -e 'assert(loadfile("libs/LibSettingsDesigner/LibSettingsDesignerConfig.lua")); assert(loadfile("libs/LibSettingsDesigner/LibSettingsDesignerUI.lua"))'
```

If the host repo has Luacheck or another lint command for the touched files, run
it. If library files are intentionally excluded, report that and provide the
syntax-check result instead.

## Handoff Report Requirements

Final reports should include:

- what changed
- whether runtime code was changed
- whether docs were checked against source code
- validation commands/results
- known limitations
- concrete next steps if anything remains

Use precise language. Do not claim source-level verification when source files
were not available.
