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
- Every user-facing string produced by the generic runtime must have a key in
  every built-in `lib.LOCALES` locale. Host-addon feature strings still belong
  to the host addon's locale table.
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

## Vendoring and BigWigsPackager

Host addons must ship their own copy of LibSettingsDesigner. Do not depend on
another addon's copy and do not register LibSettingsDesigner through LibStub.

Recommended host layout:

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

TOC include:

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
```

BigWigsPackager external:

```yaml
externals:
  libs/LibSettingsDesigner:
    url: https://github.com/R41z0r/LibSettingsDesigner.git
    branch: main
    path: runtime/LibSettingsDesigner
```

Use a version tag instead of `branch: main` for reproducible release snapshots.

`path: runtime/LibSettingsDesigner` is required because the repository also
contains docs, samples, and agent guidance. Only the runtime folder belongs in
the host addon's packaged runtime. `Assets/` must be included.

Using LibStub for unrelated dependencies such as AceLocale or LibSharedMedia is
fine. The LibStub ban applies to LibSettingsDesigner itself.

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

## Runtime Surface / Ground Truth

Before documenting or changing behavior, verify claims against:

- `runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua`
- `runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua`

Current public Config surface:

```lua
Config:RegisterAddOn(id, opts)
Config:GetAddOn(id)
Config:NormalizeID(text)
```

Current app methods:

```lua
app:RegisterCategory(data)
app:RegisterPage(data)
app:RegisterGroup(pageID, data)
app:RegisterPageNote(pageID, data)
app:RegisterControl(pageID, data)
app:RegisterControlNote(controlID, data)

app:RegisterLegacyCategory(category, data)
app:RegisterLegacySection(section, data)
app:RegisterLegacyControl(data)

app:GetCategories()
app:GetPages(categoryID)
app:GetPage(pageID)
app:GetPageControls(pageOrID)
app:SetDefaultPage(pageID)
app:GetDefaultPageID()

app:GetControlValue(control)
app:SetControlValue(control, value)
app:GetControlDefault(control)
app:IsControlEnabled(control)
app:IsControlVisible(control)
app:IsPageVisible(page)
app:IsControlCustomized(control)
app:GetPageCustomizedCount(pageOrID)
app:GetCategoryCustomizedCount(categoryID)
app:GetStats()
app:GetSearchResults(query, limit)
app:IsNewTagActive(tagID)
app:IsPageNew(page)
app:IsControlNew(control)
```

Current UI surface:

```lua
ConfigUI:Open(appOrID, pageID, focusControlID)
ConfigUI:Toggle(appOrID, pageID, focusControlID)
ConfigUI:GetFrame(appOrID)
ConfigUI.ResolveOpenTarget(app, pageID, focusControlID)
```

Do not document or call these as public runtime APIs unless they are implemented:

```lua
app:ResetControl(...)
app:ResetPage(...)
app:Search(...)
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
  getDensity = function() return MyAddonDB.profile.settingsWindow and MyAddonDB.profile.settingsWindow.density end,
  setDensity = function(value)
    MyAddonDB.profile.settingsWindow = MyAddonDB.profile.settingsWindow or {}
    MyAddonDB.profile.settingsWindow.density = value
  end,
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
| `addonFolder` / `folder` | Host addon folder name for fallback paths. |
| `assetRoot` | Path to vendored `Assets/`. |
| `db` | Function returning simple DB table. |
| `locale` | Host addon locale table. |
| `density` | Initial density, `"compact"` or `"comfortable"`, string or function. |
| `getDensity(app)` / `setDensity(density, app)` | Persist the user's selected density. |
| `showDensityButton` / `showDensityButton(app)` | Whether users can switch density; only `false` hides the button. |
| `getSize()` / `setSize(width, height)` | Persist frame size. |
| `getLocked()` / `setLocked(locked)` | Persist frame lock state. |
| `dashboard` | Dashboard table or function. |
| `isNewTag` | New badge resolver. |
| `iconTextures` | `iconKey` to texture path map. |
| `categoryIconTextures` | Category icon map. |
| `pageDescriptionKeys` / `pageDescriptionLocaleKeys` | Map page ids/keys to locale keys for descriptions. |
| `openLegacySettings` | Bridge action for legacy settings jumps. |
| `blizzardSettingsRoot` | Set `true` to add a lightweight entry in Blizzard Settings. |
| `blizzardSettingsTitle` | Optional title for the Blizzard Settings bridge entry. |
| `openSettings` | Callback used by the Blizzard Settings bridge button. |

`density` is only the initial/default layout. If the density button is visible,
the user can switch between `"compact"` and `"comfortable"`. Use `getDensity`
and `setDensity` when that choice should persist. Use
`showDensityButton = false` when the host addon wants a fixed layout.

`profile` and `version` are host-owned metadata in the current runtime. Do not
promise automatic profile/status/version rendering from these fields unless host
addon code or a custom dashboard function explicitly reads them.

## Blizzard Settings Bridge

Do not register LibSettingsDesigner pages directly into Blizzard Settings. The
library owns its standalone settings center. A host addon may optionally add one
lightweight Blizzard Settings entry that only opens the LibSettingsDesigner UI.

Default rule: leave the Blizzard Settings bridge off unless the host addon
explicitly asks for it. Many addons already have their own GUI or replace the
default settings flow; adding another Blizzard Settings entry can be duplicate
navigation.

Use the bridge only when the addon should appear in Blizzard's Settings list:

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  blizzardSettingsRoot = true,
  blizzardSettingsTitle = "My Addon",
  openSettings = function()
    ConfigUI:Open(app)
  end,
})
```

The bridge button should only open the standalone settings center. Do not mirror
or duplicate every LibSettingsDesigner page inside Blizzard Settings.

## Direct API vs Legacy Bridge Aliases

Direct `RegisterCategory`, `RegisterPage`, `RegisterGroup`, and
`RegisterControl` registrations should use canonical runtime fields. Do not
assume legacy aliases work in direct registration unless the runtime explicitly
consumes them.

Canonical direct fields:

| Object | Canonical fields |
| :----- | :--------------- |
| Category | `id`, `title`, `description`, `order`, `icon`, `iconAtlas`, `iconKey` |
| Page | `id`, `category`, `title`, `description`, `descriptionKey`, `order`, `icon`, `iconAtlas`, `iconKey`, `mainToggleID`, `pageKey`, `newTagID`, `onOpen`, `layout`, `type`, `content`, `blocks`, `infoBlocks` |
| Group | `id`, `title`, `order` |
| Control | `id`, `key`, `type`, `sType`, `label`, `description`, `default`, `dbDefault`, `getValue`, `setValue`, `getSelection`, `setSelection`, `setting`, `parentCheck`, `isEnabled`, visibility fields, search fields |

Legacy aliases are mapped by `RegisterLegacyCategory`,
`RegisterLegacySection`, and `RegisterLegacyControl`, not by plain direct
controls:

| Legacy alias | Canonical runtime field |
| :----------- | :---------------------- |
| `var` | `key` |
| `text` / `name` | `label` |
| `desc` | `description` |
| `get` | `getValue` |
| `set` | `setValue` |
| `sType` | `type` or UI type alias |

Important: in direct `RegisterControl`, `var` may become the generated control
id, but it does not become `key`. DB-backed controls must set `key`.

## Category and Page Fields

Common category fields:

| Field | Use |
| :---- | :-- |
| `id` | Stable category id. |
| `title` | User-facing category label. |
| `order` | Sidebar sort order. |
| `icon` | Texture path. |
| `iconAtlas` | Blizzard atlas name. |
| `iconKey` | Lookup key in app icon maps. |

Common page fields:

| Field | Use |
| :---- | :-- |
| `id` | Stable page id used by `ConfigUI:Open`. |
| `category` | Parent category id. |
| `title` | User-facing page title. |
| `description` / `descriptionKey` | Page card/detail summary. |
| `order` | Page sort order. |
| `icon` / `iconAtlas` / `iconKey` | Page icon source. |
| `mainToggleID` | Control id used as the page's primary feature toggle. |
| `pageKey` | Stable alternate page/tag key for wrappers and new badges. |
| `newTagID` | Stable new badge tag. |
| `onOpen` | Lightweight page-open callback. |
| `layout` / `type` | Use `"info"` for static/help pages. |
| `content` / `blocks` / `infoBlocks` | Info page content table. |
| `visible` / `isVisible` / `visibleWhen` | Show gates. |
| `hidden` / `hiddenWhen` | Hide gates. |

Use stable ids and keys. Do not derive page/control ids from localized labels.

## Control Field Reference

Common fields:

| Field | Use |
| :---- | :-- |
| `id` | Stable control identity. |
| `key` | Direct DB key under `opts.db()`. |
| `type` / `sType` | Widget type. |
| `label` | Display label. |
| `description` | Short description. |
| `default` / `dbDefault` | Reset/customized default. |
| `getValue` | Explicit reader. |
| `setValue` | Explicit writer. |
| `setting` | Existing settings object with `GetValue`/`SetValue`/default methods. |
| `groupID` / `modernGroup` | Group assignment. |
| `isEnabled` / `parentCheck` | Disabled-state gates. |
| `visible` / `isVisible` / `visibleWhen` | Visibility show gates. |
| `hidden` / `hiddenWhen` | Visibility hide gates. |
| `keywords` / `searchtags` | Search aliases. |
| `newTagID` | New badge tag. |
| `trackCustomized` | Customized-count override. |
| `refreshOnChange` | Re-render content after change. |

Use `key` for direct profile keys:

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

Avoid `key = "nested.path"` in direct LibSettingsDesigner registrations. The
runtime treats `key` as a literal table key. Use explicit getters/setters for
nested values. Do not rely on `subvar` for direct value reads/writes; it only
helps the customized-state check for legacy-shaped metadata.

Element-specific fields the agent should know. List only fields the current
runtime actively consumes as UI behavior:

| Element | Important runtime-consumed fields |
| :------ | :-------------------------------- |
| Toggle/Checkbox | `default`, `key`, `getValue`, `setValue`, `parentCheck`, `isEnabled`, `refreshOnChange` |
| Slider | `min`, `max`, `step`, `formatter`, `valueFormatter`, `suffix` |
| Dropdown/ScrollDropdown | `values`, `options`, `list`, `orderList`, `order`, `listFunc`, `optionfunc`, `menuHeight` |
| MultiDropdown | `getSelection`, `setSelection`, `isSelectedFunc`, `setSelectedFunc`, `selectionSource`, `summary`, `callback`, `menuHeight` |
| Input | `numeric`, `min`, `max`, `step`, `clampToRange`, `maxChars`, `readOnly`, `inputWidth`, `multiline` |
| Button | `buttonText`, `onClick`, `setValue`, `trackCustomized = false` |
| ColorPicker | `getColor`, `setColor`, `hasOpacity` |
| ColorOverrides | `entries`, `getColor`, `setColor`, `hasOpacity`, `colorizeLabel` |
| SoundDropdown | `soundResolver`, `previewSoundFunc`, `previewTooltip`, `playbackChannel`, `getPlaybackChannel`, `menuHeight` |
| CheckboxDropdown | `dropdownKey`, `dropdownDefault`, `dropdownValues`, `dropdownOptions`, `dropdownList`, `dropdownOrder`, `dropdownGet`, `dropdownSet` |
| ReorderList | `getEntries`, `addEntry`, `removeEntry`, `moveEntry`, `setEntryFormat`, `formatOptions`, `formatOrder`, `emptyText`, `addButtonText`, `addPopupText`, `addPopupTitle`, `numeric`, `maxChars`, `rowHeight` |
| Keybind | Legacy/fallback bridge control; prefer host wrapper or `openLegacySettings` patterns. |

Do not document these as active UI behavior unless runtime support is added:

- MultiDropdown `hideSummary`
- Input `multilineHeight`
- ColorPicker `callback`
- ColorPicker `colorizeLabel`
- ColorOverrides `getDefaultColor`

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
2. `control.setSelection(value, control)` or `control.setSelection(value)`
3. `control.setValue(value)` or `control.setValue(nil, value)`
4. `opts.db()[control.key] = value`

If in doubt, use explicit getters/setters.

## Default, Changed, and Enabled Rules

When creating or changing a value control, always define the complete state
contract. The agent should be able to answer these questions from the
registration table alone:

1. Where is the value stored?
2. What is the default value?
3. Should the control count as changed when it differs from default?
4. Can the user currently edit it?
5. Should the row stay visible or disappear when unavailable?

Use this baseline for normal persisted settings:

```lua
app:RegisterControl("general.core", {
  id = "showFrame",
  key = "showFrame",
  type = "toggle",
  label = "Show frame",
  default = true,
})
```

`key` plus `default` is enough only when the value is stored directly in
`opts.db()[key]`.

For nested, derived, migrated, or private values, provide `getValue`,
`setValue`, and a default with the same value shape that `getValue` returns:

```lua
app:RegisterControl("layout.frame", {
  id = "frameScale",
  type = "slider",
  label = "Frame scale",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  getValue = function()
    return MyAddonDB.profile.layout and MyAddonDB.profile.layout.scale or 1
  end,
  setValue = function(value)
    MyAddonDB.profile.layout = MyAddonDB.profile.layout or {}
    MyAddonDB.profile.layout.scale = tonumber(value) or 1
  end,
})
```

Changed/customized state is automatic when:

- the control has a resolvable default
- the control is enabled
- the current stored/effective value differs from the default
- `trackCustomized` is not `false`
- the control is not an action-only type such as `button` or `keybind`

Current customized-state details:

- `trackCustomized == false` disables customized tracking.
- `trackCustomized` is not evaluated as a callback in the current runtime.
- A resolvable default is required.
- Disabled controls are never customized.
- If `control.key` is set, customized requires a stored `db[key]` value. An
  absent DB key counts as default/unmodified.
- Without `control.key`, the effective current value is compared against the
  default.

There is no public `app:ResetControl` or `app:ResetPage` runtime API. The UI
top-bar Defaults button resets the current page internally. It iterates visible
page controls, resolves each default, and calls
`app:SetControlValue(control, default)`. Disabled controls are not skipped if
they are visible.

For composite controls such as color pickers, provide `key` or `setValue` if
reset and customized state should work through `SetControlValue`. `getColor` and
`setColor` alone only power the picker UI.

Use `trackCustomized = false` for controls that are runtime actions, diagnostics,
preview-only values, or rows where "changed from default" would be misleading:

```lua
app:RegisterControl("tools.actions", {
  id = "rebuildCache",
  type = "button",
  label = "Rebuild cache",
  onClick = function()
    MyAddon.RebuildCache()
  end,
  trackCustomized = false,
})
```

Use enabled gates when a row should remain visible but not editable:

```lua
parentCheck = function()
  return MyAddonDB.profile.enabled == true
end
```

Use visibility gates only when the row/page should disappear:

```lua
visibleWhen = function()
  return MyAddonDB.profile.advanced == true
end
```

Do not use `isEnabled` / `parentCheck` to describe defaults. They only control
interactivity. The default still belongs in `default`, `dbDefault`, or the
provided `setting` object.

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

`isEnabled` and `parentCheck` are both disabled-state gates. Prefer
`parentCheck` for child controls depending on a parent toggle; use `isEnabled`
for broader runtime rules such as combat lockdown, missing external data, or a
feature provider not being available. Current runtime calls these gates without
arguments. Only an explicit returned `false` disables the control. Errors or nil
results do not disable it.

Use visibility gates to remove rows/pages:

```lua
visibleWhen = function()
  return MyAddonDB.profile.advanced == true
end
```

Static visibility flags are also supported:

```lua
hidden = true
visible = false
```

Function aliases are supported for both pages and controls:

```lua
isVisible = function(control, app)
  return MyAddon.HasAdvancedMode()
end

hiddenWhen = function(control, app)
  return MyAddon.IsInRestrictedMode()
end
```

Rule of thumb:

| User should see row but not edit | Use `isEnabled` or `parentCheck` |
| Row/page should disappear | Use `visibleWhen` or `hiddenWhen` |

Resolution behavior:

- `hidden == true` hides.
- `visible == false` hides.
- `hiddenWhen(pageOrControl, app) == true` hides.
- Runtime picks one visible function in this priority: `isVisible`,
  `visibleWhen`, then function-valued `visible`.
- If the visible function errors or returns `false`, the object is hidden.

Hidden pages/controls do not render and do not participate in runtime search.

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

Use `app:GetSearchResults(query, limit)` for runtime search. There is no public
`app:Search(query)` method in the current runtime.

Runtime search returns controls. It does not currently return standalone pages.
Each control search blob includes:

- control label/title/text/id
- control description/desc
- control key/settingKey
- `control.keywords or control.searchtags`
- owning page title
- owning group title
- owning category title
- control notes

Page `keywords` and page `searchtags` are not indexed by the current runtime.
Put page-level aliases on important controls, or implement page search support
before documenting it. If both `keywords` and `searchtags` are set on a control,
the current runtime indexes `keywords`.

Good control tags include old setting names, common abbreviations, slash command
terms, module names, and user-facing terms from older UI.

`tag:new` filters active new controls.

Use `newTagID` only when the app provides `isNewTag`:

```lua
local app = Config:RegisterAddOn(addonName, {
  isNewTag = function(tagID)
    return MyAddon.NewTags
      and MyAddon.NewTags[tagID] == true
      and not (MyAddon.SeenNewTags and MyAddon.SeenNewTags[tagID] == true)
  end,
})
```

Then on a page or control:

```lua
newTagID = "FreshFeature"
```

`newTagID` values must be stable, non-localized identifiers. Prefer explicit
`newTagID` values to avoid accidental badges from ids or DB keys. Current
fallback resolution checks:

- Pages: `page.newTagID`, `page.id`, `page.pageKey`, `page.key`
- Controls: `control.newTagID`, `control.id`, `control.key`

Badge state and seen-state belong to the host addon. A page can use
`onOpen = function(page, app, state)` to mark `page.newTagID` as seen; keep that
callback lightweight and do not rebuild the settings frame from it. Wrappers
should forward `newTagID`, `keywords`, and `searchtags` so feature modules do
not need to call raw Config APIs.

## Dashboard

`opts.dashboard` may be a table or `function(app) return dashboard end`.

Runtime-supported dashboard fields:

```lua
dashboard = {
  hero = {
    title = "Settings",
    subtitle = "Configure the addon.", -- or description
    icon = "Interface\\Icons\\INV_Misc_Gear_01", -- or iconKey
  },

  cards = {
    {
      title = "Action Bars",
      description = "Configure action bar behavior.", -- or desc
      icon = "...", -- or iconKey
      pageID = "interface.action-bars",
      onClick = function() end,
    },
  },

  -- Set status = true for default status tiles, or provide a table.
  status = {
    title = "Status",
    tiles = {
      {
        icon = "...",
        atlas = "...",
        title = "Changed",
        value = "3",
        badge = "Live",
        searchQuery = "tag:new",
        onClick = function(state, app, stats) end,
      },
    },
    -- tiles may also be a function:
    -- tiles = function(app, stats) return tiles end,
  },

  -- Set features = false to disable the feature summary.
  features = {
    limit = 5,
    enabledBadge = "Enabled",
    customizedBadge = "Changed",
    enabledTitle = "Enabled features",
    customizedTitle = "Changed pages",
  },

  -- Set newEntries = false to disable the new-entry summary.
  newEntries = {
    limit = 3,
    title = "New",
  },
}
```

## Info Pages

Info pages render when `page.layout == "info"`, `page.type == "info"`, or the
page has `content`, `blocks`, or `infoBlocks`.

Current runtime expects `content`, `blocks`, or `infoBlocks` to be a table, not
a provider function.

Typical blocks:

```lua
content = {
  {
    title = "Commands",
    entries = {
      { type = "command", commands = { "/myaddon", "/myaddon config" }, desc = "Open settings." },
      { type = "button", text = "Open Website", onClick = function(entry, app) end },
      { type = "image", texture = "Interface\\Icons\\INV_Misc_QuestionMark", width = 64, height = 64 },
      { type = "spacer", height = 12 },
      { type = "text", text = "Plain information text." },
    },
  },
}
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
