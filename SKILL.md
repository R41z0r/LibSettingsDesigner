---
name: libsettingsdesigner
description: Use when creating, editing, documenting, reviewing, or integrating LibSettingsDesigner, a vendored World of Warcraft addon settings-center library with addon.LibSettingsDesigner.Config and addon.LibSettingsDesigner.UI, including categories, pages, groups, controls, dashboards, notes, info pages, wrapper bridges, examples, troubleshooting, validation, and migration away from shared LibStub distribution.
metadata:
  short-description: Work with LibSettingsDesigner settings-center library
---

# LibSettingsDesigner Skill

Use this skill for work on LibSettingsDesigner itself or on addon code that
integrates a vendored copy of LibSettingsDesigner.

LibSettingsDesigner is a vendored World of Warcraft addon settings-center
library. It has a data model and a UI renderer:

```lua
addon.LibSettingsDesigner.Config
addon.LibSettingsDesigner.UI
```

It is not a shared LibStub package. Every host addon owns and ships its own copy.

## Core Contract

Never violate these rules:

- Do not add `LibStub:NewLibrary` registration for LibSettingsDesigner.
- Do not depend on another addon's copy of LibSettingsDesigner.
- Do not put host-addon-specific feature behavior into generic library runtime
  files.
- Do not put host-addon-specific feature strings into generic library runtime
  files.
- Do not rebuild the settings frame from dropdown or MultiDropdown option-click
  callbacks.
- Do not change runtime code when the task is documentation-only.
- Do not remove LibSettingsDesigner license notices from runtime Lua/XML files
  or vendored runtime copies.
- Add the LibSettingsDesigner license notice to any new runtime Lua/XML file:

```text
LibSettingsDesigner
License: https://raw.githubusercontent.com/R41z0r/LibSettingsDesigner/main/LICENSE.md
Do not remove this notice from redistributed copies.
```

## First Steps

1. Read `AGENTS.md` in the LibSettingsDesigner folder.
2. Identify the requested scope:
   - documentation/skill only
   - runtime library code
   - host addon wrapper code
   - examples/samples
   - validation/review
3. Read the matching docs before editing:
   - Mental model: `docs/Architecture.md`
   - Setup/loading: `docs/Vendoring.md`, `docs/Quick-Start.md`
   - Field lookup: `docs/Field-Glossary.md`
   - Data model/API: `docs/API/Config-API.md`
   - UI open/toggle/state: `docs/API/UI-API.md`
   - Element behavior: `docs/Elements/<Element>.md`
   - Example workflows: `docs/Examples/<Example>.md`
   - Common issues: `docs/Troubleshooting.md`
   - Handoff checks: `docs/Validation.md`
4. If source files are present, inspect them before claiming docs match code.
5. If source files are absent, say that exact code-level verification is not
   possible and keep changes limited to documented behavior.

## Repository Map

Runtime layout in this repository:

```text
runtime/
  LibSettingsDesigner/
    LibSettingsDesigner.xml
    LibSettingsDesignerConfig.lua
    LibSettingsDesignerUI.lua
    Assets/
```

Vendored runtime layout inside a host addon:

```text
libs/
  LibSettingsDesigner/
    LibSettingsDesigner.xml
    LibSettingsDesignerConfig.lua
    LibSettingsDesignerUI.lua
    Assets/
```

Expected documentation layout:

```text
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
```

## Loading Model

The host addon loads the library XML before settings registration code:

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
```

The XML must load the data model before the UI:

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
  <Script file="LibSettingsDesignerConfig.lua" />
  <Script file="LibSettingsDesignerUI.lua" />
</Ui>
```

Then host code reads the APIs from the addon namespace:

```lua
local addonName, addon = ...
local Designer = addon.LibSettingsDesigner
local Config = Designer and Designer.Config
local ConfigUI = Designer and Designer.UI
```

## Basic App Registration

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  settingsTitle = "My Addon Settings",
  dashboardTitle = "Dashboard",
  addonFolder = addonName,
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  density = "compact",
  db = function() return MyAddonDB.profile end,
  locale = L,
})
```

Register in this order:

```lua
app:RegisterCategory(data)
app:RegisterPage(data)
app:RegisterGroup(pageID, data)          -- optional
app:RegisterPageNote(pageID, data)       -- optional
app:RegisterControl(pageID, data)
app:RegisterControlNote(controlID, data) -- optional
```

Minimal page:

```lua
app:RegisterCategory({
  id = "general",
  title = GENERAL or "General",
  order = 100,
})

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
  description = "Enable this addon.",
  default = true,
})
```

Open the UI:

```lua
ConfigUI:Open(app)
ConfigUI:Open(app, "general.core")
ConfigUI:Open(app, "general.core", "enabled")
ConfigUI:Toggle(app)
```

`Open` and `Toggle` may also receive the registered addon id:

```lua
ConfigUI:Open("MyAddon", "general.core")
```

## App Options Reference

| Field | Use |
| :---- | :-- |
| `title` | Short addon title. |
| `settingsTitle` | Window title. |
| `dashboardTitle` | Dashboard navigation label. |
| `icon` | Main addon icon texture. |
| `addonFolder` | Host addon folder name for fallback paths. |
| `assetRoot` | Path to vendored `Assets/`. |
| `db` | Function returning simple DB table. |
| `profile` | Optional profile table provider. |
| `locale` | Host addon locale table. |
| `density` | `"compact"` or `"comfortable"`, string or function. |
| `showDensityButton` | Whether users can switch density. |
| `getSize` / `setSize` | Persist frame size. |
| `getLocked` / `setLocked` | Persist frame lock state. |
| `dashboard` | Dashboard table or function. |
| `version` | Version string or function. |
| `isNewTag` | New badge resolver. |
| `iconTextures` | `iconKey` to texture path map. |
| `categoryIconTextures` | Category icon map. |
| `openLegacySettings` | Bridge action for legacy settings jumps. |

## Control Field Reference

Common fields:

| Field | Use |
| :---- | :-- |
| `id` | Stable control identity. |
| `key` / `var` | Direct DB key under `opts.db()`. |
| `type` | Widget type. |
| `label` / `text` / `name` | Display label. |
| `description` / `desc` | Short description. |
| `default` / `dbDefault` | Reset/customized default. |
| `getValue` / `get` | Explicit reader. |
| `setValue` / `set` | Explicit writer. |
| `groupID` / `modernGroup` | Group assignment. |
| `isEnabled` / `parentCheck` | Disabled-state gates. |
| `visibleWhen` / `hiddenWhen` | Visibility gates. |
| `keywords` / `searchtags` | Search aliases. |
| `newTagID` | New badge tag. |
| `trackCustomized` | Customized-count override. |
| `refreshOnChange` | Re-render content after change. |

Use `key`/`var` only for direct profile keys:

```lua
-- Reads/writes MyAddonDB.profile.enabled
key = "enabled"
```

Use explicit getters/setters for nested DB:

```lua
getValue = function()
  return MyAddonDB.profile.bars and MyAddonDB.profile.bars.scale or 1
end,
setValue = function(value)
  MyAddonDB.profile.bars = MyAddonDB.profile.bars or {}
  MyAddonDB.profile.bars.scale = tonumber(value) or 1
  MyAddon.RefreshBars()
end
```

## Value Resolution Contract

Default resolution order:

1. `control.default`
2. `control.dbDefault`
3. `control.setting:GetDefaultValue()` or `control.setting:GetDefault()`

Value read order:

1. `control.setting:GetValue()`
2. `control.getSelection(control)` or `control.getSelection()`
3. `control.getValue()`
4. `opts.db()[control.key]`
5. `control.default`

Value write order:

1. `control.setting:SetValue(value)`
2. `control.setSelection(selection)` for MultiDropdown map writes
3. `control.setValue(value)`
4. `opts.db()[control.key] = value`

If in doubt, use explicit getters/setters.

## Element Routing

Read the specific element page before changing examples or behavior:

| Task | Read |
| :--- | :--- |
| Categories/sidebar | `docs/Elements/Category.md` |
| Pages/cards/detail views | `docs/Elements/Page.md` |
| Groups/headings | `docs/Elements/Group.md` |
| Boolean controls | `docs/Elements/Toggle.md` |
| Numeric ranges | `docs/Elements/Slider.md` |
| Single choice lists | `docs/Elements/Dropdown.md` |
| Multi-select lists | `docs/Elements/MultiDropdown.md` |
| Text/numeric/multiline entry | `docs/Elements/Input.md` |
| Action rows | `docs/Elements/Button.md` |
| Single colors | `docs/Elements/ColorPicker.md` |
| Multiple keyed colors | `docs/Elements/ColorOverrides.md` |
| Sound selection/preview | `docs/Elements/SoundDropdown.md` |
| Checkbox plus dropdown rows | `docs/Elements/CheckboxDropdown.md` |
| Ordered editable lists | `docs/Elements/ReorderList.md` |
| Hover help/rich notes | `docs/Elements/Notes.md` |
| Dashboard content | `docs/Elements/Dashboard.md` |
| Static help pages | `docs/Elements/InfoPage.md` |

## Element Patterns

Toggle:

```lua
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "Enabled",
  default = true,
})
```

Slider:

```lua
app:RegisterControl("layout.frame", {
  id = "scale",
  key = "scale",
  type = "slider",
  label = "Scale",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  formatter = function(value)
    return string.format("%.0f%%", (tonumber(value) or 1) * 100)
  end,
})
```

Dropdown:

```lua
app:RegisterControl("layout.frame", {
  id = "anchor",
  key = "anchor",
  type = "dropdown",
  label = "Anchor",
  list = { LEFT = "Left", CENTER = "Center", RIGHT = "Right" },
  orderList = { "LEFT", "CENTER", "RIGHT" },
  default = "CENTER",
})
```

MultiDropdown:

```lua
app:RegisterControl("group.roles", {
  id = "roles",
  type = "multidropdown",
  label = "Roles",
  options = { tank = "Tank", healer = "Healer", damage = "Damage" },
  orderList = { "tank", "healer", "damage" },
  getSelection = function()
    return MyAddonDB.profile.roles or {}
  end,
  setSelectedFunc = function(value, selected)
    MyAddonDB.profile.roles = MyAddonDB.profile.roles or {}
    MyAddonDB.profile.roles[value] = selected and true or nil
    MyAddon.RefreshRoles()
  end,
  default = {},
})
```

Info page:

```lua
app:RegisterPage({
  id = "help.quick-reference",
  category = "help",
  title = "Quick Reference",
  layout = "info",
  content = {
    {
      title = "Slash Commands",
      entries = {
        { type = "command", commands = { "/myaddon" }, desc = "Open settings." },
      },
    },
  },
})
```

## Dropdown and MultiDropdown Rules

Dropdowns:

- Use `list` / `options` for static maps.
- Use `orderList` / `order` for deterministic ordering.
- Use `listFunc` / `optionfunc` for runtime lists.
- Use `menuHeight` for large lists.

MultiDropdowns:

- Store selections as boolean maps: `selection[value] == true`.
- Deselect by removing the key or assigning `nil`.
- Keep `setSelectedFunc` and `setSelection` focused on data and lightweight
  runtime preview changes.
- Do not rebuild the settings frame while the menu is open.

## Visibility and Enablement Rules

Use enabled gates to keep rows visible but disabled:

```lua
parentCheck = function()
  return MyAddonDB.profile.enabled == true
end
```

Use visibility gates to remove rows/pages:

```lua
visibleWhen = function()
  return MyAddonDB.profile.advanced == true
end
```

Rule of thumb:

| User should see row but not edit | Use `isEnabled` or `parentCheck` |
| Row/page should disappear | Use `visibleWhen` or `hiddenWhen` |

## Notes and Tooltip Rules

Use `description` for short inline text.

Use one of these for hover help:

- `note`
- `notes`
- `richNote`
- `richNotes`

Simple note:

```lua
note = {
  title = "Details",
  text = "Configure layout and behavior in Edit Mode.",
}
```

Rich note:

```lua
notes = {
  {
    title = "Preview",
    blocks = {
      { text = "Use preview mode before entering combat." },
      { type = "spacer", height = 8 },
      { image = "Interface\\AddOns\\MyAddon\\Media\\preview.tga", width = 256, height = 144 },
    },
  },
}
```

Do not hard-code panel height guesses for note behavior. Existing note text uses
rendered `FontString:GetStringHeight()` measurement and removes the final
inter-row gap before sizing the panel so top and bottom padding remain even.

## Search and New Badge Rules

Use search aliases when the visible label is not enough:

```lua
keywords = { "alias", "display name", "old setting name" }
```

Use `newTagID` only when the app provides `isNewTag`:

```lua
local app = Config:RegisterAddOn(addonName, {
  isNewTag = function(tagID)
    return MyAddon.NewTags and MyAddon.NewTags[tagID] == true
  end,
})
```

Then on a page or control:

```lua
newTagID = "FreshFeature"
```

## Wrapper Bridge Pattern

If a host addon has settings wrappers, feature modules should use those wrappers
instead of raw Config/UI calls.

Wrapper layer methods:

```lua
app:RegisterLegacyCategory(category, data)
app:RegisterLegacySection(section, data)
app:RegisterLegacyControl(data)
```

Wrapper example:

```lua
local section = addon.SettingsCreateExpandableSection(category, {
  name = L["myFeature"],
  description = L["myFeatureDesc"],
  configPageID = "interface.my-feature",
  iconKey = "settingspage",
})

addon.SettingsCreateCheckbox(category, {
  var = "myFeatureEnabled",
  text = L["myFeatureEnabled"],
  desc = L["myFeatureEnabledDesc"],
  default = false,
  parentSection = section,
  func = function(value)
    addon.db.myFeatureEnabled = value == true
    addon.RefreshMyFeature()
  end,
})
```

Internal wrapper mapping example:

```lua
app:RegisterLegacyControl({
  parentSection = data.parentSection,
  id = data.id or data.var,
  key = data.var,
  type = "toggle",
  label = data.text,
  description = data.desc,
  default = data.default,
  setValue = data.func,
})
```

## Frame State Access

The rendered frame stores internal state here:

```lua
frame._LibSettingsDesignerState
```

Use it only for narrow integration points, such as refreshing the current page
after external runtime data changed:

```lua
local frame = addon.ConfigCenterFrame
local state = frame and frame._LibSettingsDesignerState
if frame and frame:IsShown() and state and state.RenderContent then
  state:RenderContent()
end
```

Do not use frame state as a replacement for proper control setters or wrapper
callbacks.

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

For documentation-only tasks:

```bash
rg -n 'TO[D]O|TB[D]|FIXM[E]' README.md AGENTS.md SKILL.md docs
rg -n '\[[^]]+\]\([^)]*\)' README.md AGENTS.md SKILL.md docs
```

For runtime code tasks when source files are present:

```bash
lua -e 'assert(loadfile("runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua")); assert(loadfile("runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua"))'
```

When validating a host addon that vendors the library, check that addon's local
copy instead:

```bash
lua -e 'assert(loadfile("libs/LibSettingsDesigner/LibSettingsDesignerConfig.lua")); assert(loadfile("libs/LibSettingsDesigner/LibSettingsDesignerUI.lua"))'
```

If the host addon has Luacheck or tests for the touched files, run them. If the
library files are intentionally excluded from lint, say so and report the syntax
check instead.

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
