<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Getting the API](#getting-the-api)
- [Top-Level Methods](#top-level-methods)
- [RegisterAddOn](#registeraddon)
- [App Options](#app-options)
- [Registration Methods](#registration-methods)
- [Legacy Bridge Methods](#legacy-bridge-methods)
- [Lookup and Navigation Methods](#lookup-and-navigation-methods)
- [Value Methods](#value-methods)
- [Visibility and Enablement Methods](#visibility-and-enablement-methods)
- [Search and Stats](#search-and-stats)
- [Registration Order Example](#registration-order-example)

</details>

## [Overview][Top]

The Config API owns the settings data model:

- apps
- categories
- pages
- groups
- controls
- page/control notes
- defaults
- value reads/writes
- customized-state checks
- reset handling
- visibility and enabled-state checks
- search metadata
- legacy wrapper bridge registration

It does not render the settings center. Rendering belongs to
`addon.LibSettingsDesigner.UI`.

## [Getting the API][Top]

```lua
local addonName, addon = ...
local Config = addon.LibSettingsDesigner and addon.LibSettingsDesigner.Config
```

Always load `libs\LibSettingsDesigner\LibSettingsDesigner.xml` before the file
that uses `Config`.

## [Top-Level Methods][Top]

| Method | Purpose |
| :----- | :------ |
| `RegisterAddOn(id, opts)` | Creates or updates one settings app and returns the app object. |
| `GetAddOn(id)` | Returns a registered app by id. |
| `NormalizeID(text)` | Normalizes display-ish text into stable id-like text. Prefer explicit ids when possible. |

## [RegisterAddOn][Top]

```lua
local app = Config:RegisterAddOn(addonName, opts)
```

`addonName` should normally be the host addon's real addon id from:

```lua
local addonName, addon = ...
```

Minimal example:

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  settingsTitle = "My Addon Settings",
  addonFolder = addonName,
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  db = function() return MyAddonDB.profile end,
  locale = L,
})
```

Calling `RegisterAddOn` again with the same id should be treated as updating or
reusing the same app registration. Keep registration deterministic and avoid
registering the same page/control from multiple unrelated code paths.

`density` controls the initial layout only. If the density button is visible,
users can switch between compact and comfortable layouts. Provide `getDensity`
and `setDensity` when that choice should persist in SavedVariables. Set
`showDensityButton = false` for a fixed layout with no user-facing switch.

## [App Options][Top]

| Field | Type | Purpose |
| :---- | :--- | :------ |
| `title` | string | Short addon title used in dashboard/sidebar areas. |
| `settingsTitle` | string | Window title. |
| `dashboardTitle` | string | Dashboard sidebar label. |
| `icon` | string | Main addon icon texture. |
| `addonFolder` / `folder` | string | Folder name used for fallback asset paths. |
| `assetRoot` | string | Explicit path to vendored LibSettingsDesigner assets. |
| `db` | function | Returns the table used for simple `control.key` reads/writes. |
| `locale` | table | Host addon locale table. |
| `colors` / `colorTable` / `themeColors` | table/function | Optional global UI theme color overrides. Missing keys keep defaults. |
| `borders` / `themeBorders` / `borderAssets` | table/function | Optional global UI border asset overrides. Missing keys keep defaults. |
| `density` | string/function | Initial density, `"compact"` or `"comfortable"`. |
| `getDensity(app)` / `setDensity(density, app)` | function | Read/write the user's selected density. |
| `showDensityButton` / `showDensityButton(app)` | boolean/function | Whether users can switch density; only `false` hides the button. |
| `getSize()` / `setSize(width, height)` | function | Persist settings window size. |
| `getLocked()` / `setLocked(locked)` | function | Persist whether the frame can be moved/resized. |
| `dashboard` | table/function | Dashboard hero, cards, status, features, new entries. |
| `isNewTag` | function | Returns whether a tag should show a new badge. |
| `iconTextures` | table | Map `iconKey` to texture path. |
| `categoryIconTextures` | table | Map category ids/keys to texture path. |
| `pageDescriptionKeys` / `pageDescriptionLocaleKeys` | table | Map page ids/keys to locale keys for page descriptions. |
| `openLegacySettings` | function | Called by controls that should jump to legacy/Blizzard settings. |
| `blizzardSettingsRoot` | boolean | `true` registers a lightweight Blizzard Settings bridge category. |
| `blizzardSettingsTitle` | string | Title used for the Blizzard Settings bridge category. |
| `openSettings(app)` | function | Called by the Blizzard Settings bridge button. |

`profile` and `version` are host-owned metadata in the current runtime. Do not
expect automatic profile/status/version rendering from these fields unless host
addon code or a custom dashboard function explicitly reads them.

## [Registration Methods][Top]

### `app:RegisterCategory(data)`

Registers a top-level sidebar/category bucket.

```lua
app:RegisterCategory({
  id = "interface",
  title = INTERFACE_LABEL or "Interface",
  order = 100,
  iconAtlas = "hud-microbutton-character-up",
})
```

Required: `id`.

Common fields: `title`, `order`, `icon`, `iconAtlas`, `iconKey`.

### `app:RegisterPage(data)`

Registers a page under a category.

```lua
app:RegisterPage({
  id = "interface.action-bars",
  category = "interface",
  title = "Action Bars",
  description = "Configure action bar behavior.",
  iconKey = "actionbar",
  mainToggleID = "actionBarsEnabled",
  order = 100,
})
```

Required: `id`, `category`, `title`.

Pages may provide `onOpen = function(page, app, state)` for host-addon side
effects such as marking a `newTagID` as seen. Keep the callback lightweight and
avoid rebuilding the settings frame from it.

Use `layout = "info"` or `type = "info"` and table-based `content`, `blocks`,
or `infoBlocks` for help/static pages.

Use `layout = "custom"` or `type = "custom"` when a host addon needs to render
specialized content inside a LibSettingsDesigner page. Custom pages can provide
`getHeight`, `render`, `refresh`, `release`, and `searchEntries`; see
[Custom](../Elements/Custom.md).

### `app:RegisterGroup(pageID, data)`

Registers a heading/section inside one page.

```lua
app:RegisterGroup("interface.action-bars", {
  id = "visibility",
  title = "Visibility",
  order = 200,
})
```

Direct controls join the group with:

```lua
groupID = "visibility"
```

`modernGroup` is a wrapper/legacy alias and should be mapped through
`RegisterLegacyControl` or host wrapper code before direct registration.

### `app:RegisterControl(pageID, data)`

Registers a settings row/control inside a page.

```lua
app:RegisterControl("interface.action-bars", {
  id = "actionBarMouseover",
  key = "actionBarMouseover",
  type = "toggle",
  label = "Mouseover",
  description = "Fade action bars until hovered.",
  default = false,
})
```

Core fields are documented in [Field Glossary](../Field-Glossary.md). Element
specific fields are documented under [Elements](../Elements/Elements.md).

### `app:RegisterPageNote(pageID, data)`

Adds note/help content to a page.

```lua
app:RegisterPageNote("interface.action-bars", {
  title = "Combat lockdown",
  text = "Some layout changes may only apply out of combat.",
  order = 10,
})
```

### `app:RegisterControlNote(controlID, data)`

Adds note/help content to a control.

```lua
app:RegisterControlNote("actionBarMouseover", {
  title = "Tip",
  text = "Use this together with opacity controls for a cleaner UI.",
  order = 10,
})
```

## [Legacy Bridge Methods][Top]

These methods are for host addons that already have settings wrapper helpers.
Feature modules should normally call the host wrapper, and the wrapper calls
LibSettingsDesigner.

| Method | Purpose |
| :----- | :------ |
| `RegisterLegacyCategory(category, data)` | Maps a legacy/Blizzard settings category to a modern category. |
| `RegisterLegacySection(section, data)` | Maps an expandable section to a modern page. |
| `RegisterLegacyControl(data)` | Converts wrapper metadata to a modern control. |

Wrapper-side example:

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

See [Wrapper Bridge Pattern](../Examples/Wrapper-Bridge-Pattern.md).

## [Lookup and Navigation Methods][Top]

| Method | Returns / does |
| :----- | :------------- |
| `GetCategories()` | Sorted visible categories. |
| `GetPages(categoryID)` | Visible pages, optionally filtered by category. |
| `GetPage(pageID)` | One registered page. |
| `GetPageControls(pageOrID)` | Visible controls for one page. |
| `SetDefaultPage(pageID)` | Sets the app default page. |
| `GetDefaultPageID()` | Returns the app default page id. |

Use stable ids when opening pages or wiring page cards:

```lua
ConfigUI:Open(app, "interface.action-bars", "actionBarMouseover")
```

## [Value Methods][Top]

| Method | Purpose |
| :----- | :------ |
| `GetControlValue(control)` | Reads a control value using documented resolution order. |
| `SetControlValue(control, value)` | Writes a control value using documented resolution order. |
| `GetControlDefault(control)` | Resolves a control default. |
| `IsControlCustomized(control)` | Returns whether the current value differs from default. |

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

There is no public `app:ResetControl` or `app:ResetPage` runtime API. The UI
Defaults button resets the current page internally by resolving each visible
control default and calling `app:SetControlValue(control, default)`.

Use explicit getter/setter fields for nested DB values:

```lua
app:RegisterControl("bars.layout", {
  id = "scale",
  type = "slider",
  label = "Scale",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  getValue = function()
    return MyAddonDB.profile.bars and MyAddonDB.profile.bars.scale or 1
  end,
  setValue = function(value)
    MyAddonDB.profile.bars = MyAddonDB.profile.bars or {}
    MyAddonDB.profile.bars.scale = tonumber(value) or 1
    MyAddon.RefreshBars()
  end,
})
```

## [Visibility and Enablement Methods][Top]

| Method | Purpose |
| :----- | :------ |
| `IsControlEnabled(control)` | Resolves whether a row is interactive. |
| `IsControlVisible(control)` | Resolves whether a control should render. |
| `IsPageVisible(page)` | Resolves whether a page should render. |

Use visibility gates to remove a row/page:

```lua
visibleWhen = function(control, app)
  return MyAddon.HasAdvancedMode()
end
```

Use enabled gates to keep a row visible but disabled:

```lua
parentCheck = function()
  return MyAddonDB.profile.enabled == true
end
```

## [Search and Stats][Top]

| Method | Purpose |
| :----- | :------ |
| `GetSearchResults(query, limit)` | Returns matching controls. |
| `GetStats()` | Returns counts for dashboard/status UI. |

Search returns controls. It uses control labels, ids, keys, descriptions,
owning page/group/category titles, control notes, and explicit
`control.keywords or control.searchtags`. Page `keywords` and `searchtags` are
not indexed by the current runtime.

Example:

```lua
app:RegisterControl("interface.names", {
  id = "showNicknames",
  key = "showNicknames",
  type = "toggle",
  label = "Show nicknames",
  keywords = { "alias", "display name", "social" },
  default = false,
})
```

## [Registration Order Example][Top]

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  settingsTitle = "My Addon Settings",
  addonFolder = addonName,
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  db = function() return MyAddonDB.profile end,
})

app:RegisterCategory({ id = "general", title = GENERAL or "General", order = 100 })

app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "Core",
  description = "Main addon behavior.",
  order = 100,
})

app:RegisterGroup("general.core", {
  id = "behavior",
  title = "Behavior",
  order = 100,
})

app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  groupID = "behavior",
  type = "toggle",
  label = ENABLE or "Enable",
  default = true,
})
```

[//]: # (Links)
[Top]: #Top
