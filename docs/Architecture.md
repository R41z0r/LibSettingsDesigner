<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Mental Model](#mental-model)
- [Runtime Pieces](#runtime-pieces)
- [Data Flow](#data-flow)
- [Registration Lifecycle](#registration-lifecycle)
- [Value Lifecycle](#value-lifecycle)
- [Rendering Lifecycle](#rendering-lifecycle)
- [Extension Points](#extension-points)
- [Boundaries](#boundaries)
- [Naming and Compatibility](#naming-and-compatibility)

</details>

## [Mental Model][Top]

LibSettingsDesigner is a **vendored settings-center renderer** for World of
Warcraft addons.

It has two responsibilities:

1. Store settings metadata in a predictable data model.
2. Render that metadata as a modern settings center.

Feature modules should not manually build every settings row. They should
register categories, pages, groups, controls, notes, and dashboard metadata.
The UI renderer then turns that metadata into the actual frame.

The library is intentionally vendored. Every addon ships its own copy and loads
it into the host addon's namespace:

```lua
addon.LibSettingsDesigner.Config
addon.LibSettingsDesigner.UI
```

It is not a global LibStub library and should not be shared between addons.

## [Runtime Pieces][Top]

In this repository, the runtime source is isolated under
`runtime/LibSettingsDesigner/`. A consuming addon should copy that folder to its
own `libs/LibSettingsDesigner/` path. Documentation under `docs/` is not part of
the in-game runtime.

Expected runtime files inside a host addon:

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

| Piece | Owns | Should not own |
| :---- | :--- | :------------- |
| `LibSettingsDesignerConfig.lua` | Apps, categories, pages, groups, controls, defaults, value reads/writes, visibility, search metadata, customized counts, legacy bridge mapping. | Rendering details, textures, frame layout, addon-specific feature behavior. |
| `LibSettingsDesignerUI.lua` | Main frame, dashboard, sidebar, page cards, detail pages, widgets, notes, search box, density, frame size/lock, open/toggle helpers. | Addon-specific feature strings, feature business logic, global shared-lib registration. |
| `Assets/` | Reusable library UI art such as borders, arrows, close buttons, and generic UI skin pieces. | Host-addon feature icons unless they are intended to be reusable library art. |
| Host addon wrappers | Compatibility with existing settings helpers, localization, module-specific callbacks, defaults, runtime refresh. | Core renderer behavior that belongs in the library. |

## [Data Flow][Top]

The normal flow looks like this:

```text
Host addon loads LibSettingsDesigner.xml
  -> LibSettingsDesignerConfig.lua creates addon.LibSettingsDesigner.Config
  -> LibSettingsDesignerUI.lua creates addon.LibSettingsDesigner.UI
  -> host addon calls Config:RegisterAddOn(addonName, opts)
  -> host addon registers categories/pages/groups/controls
  -> user opens ConfigUI:Open(app)
  -> UI reads the Config model and renders the settings center
  -> user changes a control
  -> Config writes value through setting/setValue/db key
  -> optional callback refreshes runtime addon feature
  -> UI updates row/customized/search/dashboard state as needed
```

Keep this separation clean. The metadata should describe the settings. The
setter should persist the setting and refresh the affected addon feature. The UI
should render and interact; it should not know feature-specific rules.

## [Registration Lifecycle][Top]

Register structure in this order:

1. `Config:RegisterAddOn(addonID, opts)`
2. `app:RegisterCategory(data)`
3. `app:RegisterPage(data)`
4. `app:RegisterGroup(pageID, data)` when the page needs headings/sections
5. `app:RegisterPageNote(pageID, data)` when the page needs explanatory notes
6. `app:RegisterControl(pageID, data)`
7. `app:RegisterControlNote(controlID, data)` when a control needs extra notes

Minimal shape:

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  settingsTitle = "My Addon Settings",
  addonFolder = addonName,
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  db = function() return MyAddonDB.profile end,
  locale = L,
})

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
  description = "Enable the addon.",
  default = true,
})
```

### Stable ids

Use stable ids for everything:

- category ids: `interface`, `profiles`, `help`
- page ids: `interface.action-bars`, `profiles.import-export`
- group ids: `visibility`, `layout`, `advanced`
- control ids: `actionBarMouseover`, `profileName`

Do not use display text as an id when the text can be localized or renamed.
Renaming a label should not break saved UI state, open targets, search focus, or
wrapper mappings.

## [Value Lifecycle][Top]

A control value can come from several sources. Prefer the simplest source that
matches the setting.

### Simple DB-backed setting

Use `key` when the value lives directly under `opts.db()`. `var` is a
legacy/wrapper alias and is not mapped to `key` by direct `RegisterControl`:

```lua
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "Enabled",
  default = true,
})
```

This reads/writes:

```lua
MyAddonDB.profile.enabled
```

### Explicit getter/setter

Use explicit `getValue`/`setValue` for nested tables, private DBs,
per-character values, derived values, or compatibility fallbacks:

```lua
app:RegisterControl("bars.layout", {
  id = "barScale",
  type = "slider",
  label = "Bar scale",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  getValue = function()
    local bars = MyAddonDB.profile.bars
    return bars and bars.scale or 1
  end,
  setValue = function(value)
    MyAddonDB.profile.bars = MyAddonDB.profile.bars or {}
    MyAddonDB.profile.bars.scale = tonumber(value) or 1
    MyAddon.RefreshBars()
  end,
})
```

### Default resolution

Documented default resolution order:

1. `control.default`
2. `control.dbDefault`
3. `control.setting:GetDefaultValue()` or `control.setting:GetDefault()`

Use `default` for most controls. Use `dbDefault` when the stored DB default is
computed or shared with an existing settings system.

### Read/write resolution

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

When behavior matters, prefer explicit getters/setters instead of relying on
fallbacks.

## [Rendering Lifecycle][Top]

The UI API opens a rendered settings center:

```lua
ConfigUI:Open(app)
ConfigUI:Open(app, "interface.action-bars")
ConfigUI:Open(app, "interface.action-bars", "barScale")
ConfigUI:Toggle(app)
```

`Open` and `Toggle` accept either the app object or the registered addon id:

```lua
ConfigUI:Open("MyAddon", "general.core")
```

The rendered frame stores internal state at:

```lua
frame._LibSettingsDesignerState
```

Treat that state as an internal integration point. Use it only for narrow cases,
such as refreshing the currently rendered page after an external editor changed
metadata or runtime dropdown options:

```lua
local frame = addon.ConfigCenterFrame
local state = frame and frame._LibSettingsDesignerState
if frame and frame:IsShown() and state and state.RenderContent then
  state:RenderContent()
end
```

Do not use frame-state access as a general replacement for proper setters,
control callbacks, or wrapper helper updates.

## [Extension Points][Top]

| Extension point | Use it for | Documentation |
| :-------------- | :--------- | :------------ |
| `opts.dashboard` | Dashboard hero/cards/status/features/new entries. | [Dashboard](Elements/Dashboard.md) |
| `layout = "info"` and `content` | Static help/reference pages. | [InfoPage](Elements/InfoPage.md) |
| `note`, `notes`, `richNote`, `richNotes` | Hover help and rich explanations. | [Notes](Elements/Notes.md) |
| `keywords`, `searchtags` | Search aliases and discoverability. | [Search and New Badges](Examples/Search-And-New-Badges.md) |
| `newTagID` + `opts.isNewTag` | New-feature badges. | [Search and New Badges](Examples/Search-And-New-Badges.md) |
| legacy registration methods | Bridge existing addon settings wrappers. | [Wrapper Bridge Pattern](Examples/Wrapper-Bridge-Pattern.md) |
| `getSize`/`setSize`, `getLocked`/`setLocked` | Persist settings window state. | [UI API](API/UI-API.md) |

## [Boundaries][Top]

Do:

- Keep the library generic.
- Keep addon strings in the host addon's locale table.
- Keep feature-specific runtime changes inside host addon callbacks.
- Keep wrapper helpers thin and predictable.
- Keep ids stable even when labels change.
- Keep assets for the library under the vendored library folder.

Do not:

- Register LibSettingsDesigner with `LibStub:NewLibrary`.
- Depend on another addon's copy of the library.
- Add host-addon feature logic to `LibSettingsDesignerUI.lua`.
- Hard-code host-addon feature names in reusable library docs or code.
- Rebuild the entire settings frame from dropdown or MultiDropdown click
  callbacks.
- Store booleans as strings.
- Use localized text as ids.

## [Naming and Compatibility][Top]

Use the current names everywhere:

```lua
LibSettingsDesignerConfig.lua
LibSettingsDesignerUI.lua
addon.LibSettingsDesigner.Config
addon.LibSettingsDesigner.UI
frame._LibSettingsDesignerState
```

[//]: # (Links)
[Top]: #Top
