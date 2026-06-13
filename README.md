# LibSettingsDesigner

LibSettingsDesigner is a vendored settings-center library.
It combines a data model (`addon.LibSettingsDesigner.Config`) with the rendered
settings window (`addon.LibSettingsDesigner.UI`).

This repository separates runtime files from documentation:

- Runtime to vendor into an addon: [runtime/LibSettingsDesigner](runtime/LibSettingsDesigner)
- Wiki-style documentation: [docs/Home.md](docs/Home.md)
- AI agent guidance and repo instructions: [SKILL.md](SKILL.md), [AGENTS.md](AGENTS.md)

The library is intentionally kept as a project-vendored dependency. Do not ship
it as a standalone LibStub library package and do not depend on a global copy
from another addon. Each addon that uses it should include its own copy under
that addon's `libs/LibSettingsDesigner` folder.

## Goals

- Register settings as structured metadata instead of hand-building every row.
- Keep categories, pages, groups, controls, search, defaults, reset, and "new"
  badges in one model.
- Render a complete settings center with dashboard, sidebar, search, compact
  density, page cards, info pages, notes, and common control widgets.
- Bridge legacy settings wrappers into the modern settings center while keeping
  feature modules small.
- Keep the documentation useful for humans and AI agents by pairing field
  references with realistic examples, troubleshooting notes, and validation
  checklists.

## Documentation Map

| Need | Read |
| --- | --- |
| Understand how the library is structured | [Architecture](docs/Architecture.md) |
| Install/copy the library into an addon | [Vendoring](docs/Vendoring.md) |
| Build the first settings page | [Quick Start](docs/Quick-Start.md) |
| Look up fields and aliases | [Field Glossary](docs/Field-Glossary.md) |
| Check public Config methods | [Config API](docs/API/Config-API.md) |
| Open/toggle/refresh the rendered UI | [UI API](docs/API/UI-API.md) |
| Pick the right widget type | [Elements](docs/Elements/Elements.md) |
| Copy a complete sample | [Complete Settings Center](docs/Examples/Complete-Settings-Center.md) |
| Fix common integration issues | [Troubleshooting](docs/Troubleshooting.md) |
| Validate and report changes | [Validation](docs/Validation.md) |
| Guide AI agents and contributors | [AGENTS](AGENTS.md) and [Skill](SKILL.md) |

## Vendoring Rule

LibSettingsDesigner does not register itself through LibStub. The library is
loaded directly into the host addon's namespace:

```lua
addon.LibSettingsDesigner.Config
addon.LibSettingsDesigner.UI
```

The library must be treated as vendored code:

- Include the files directly from your addon.
- Keep assets under your addon's copy of `libs/LibSettingsDesigner/Assets`.
- Set `assetRoot` to your addon's vendored asset path.
- Do not publish this folder as a shared dependency on CurseForge/Wago.
- Do not add `LibStub:NewLibrary` registration for this library.
- Do not rely on another addon's copy being present.
- Do not make feature modules call the raw libs when the addon has wrapper
  helpers for settings creation.

Recommended layout:

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
    API/
    Elements/
    Examples/
  AGENTS.md
  SKILL.md
  README.md
```

Recommended TOC include:

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
```

## Files

- `runtime/LibSettingsDesigner/LibSettingsDesigner.xml`: load order for the data model and UI renderer.
- `runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua`: app registry, categories, pages, groups, controls,
  values, defaults, customization checks, reset handling, and search metadata.
- `runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua`: rendered frame, dashboard, sidebar, page layout,
  widgets, notes, search, density, frame size/lock persistence, and open/toggle
  helpers.
- `runtime/LibSettingsDesigner/Assets/`: window border, background, close button, collapse arrows, dropdown
  arrows, and related UI art.

## Basic Setup

```lua
local addonName, addon = ...
local LibSettingsDesigner = addon.LibSettingsDesigner
local Config = LibSettingsDesigner and LibSettingsDesigner.Config
local ConfigUI = LibSettingsDesigner and LibSettingsDesigner.UI

local app = Config:RegisterAddOn("MyAddon", {
  title = "My Addon",
  settingsTitle = "My Addon Settings",
  dashboardTitle = "Dashboard",
  icon = "Interface\\AddOns\\MyAddon\\Icon.tga",
  addonFolder = "MyAddon",
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  density = "compact",
  db = function() return MyAddonDB.profile end,
  profile = function() return MyAddonDB.profile end,
  locale = L,
})

app:RegisterCategory({
  id = "general",
  title = GENERAL or "General",
  order = 100,
  iconAtlas = "communities-icon-chat",
})

app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "Core",
  description = "Main addon behavior.",
  iconKey = "settingspage",
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

ConfigUI:Open(app)
```

## App Options

`Config:RegisterAddOn(addonID, opts)` creates or updates one settings app.

Common options:

| Field | Type | Purpose |
| --- | --- | --- |
| `title` | string | Short addon title used in dashboard/sidebar areas. |
| `settingsTitle` | string | Window title. |
| `dashboardTitle` | string | Dashboard sidebar label. |
| `icon` | string | Main addon icon texture. |
| `addonFolder` | string | Folder name used for default asset path fallback. |
| `assetRoot` | string | Explicit path to vendored LibSettingsDesigner assets. |
| `db` | function | Returns the table used for simple `control.key` reads/writes. |
| `profile` | function | Optional profile table provider. |
| `locale` | table | Locale table for UI labels. |
| `density` | string/function | `"compact"` or `"comfortable"`. |
| `showDensityButton` | boolean/function | Whether users can switch density. |
| `getSize` / `setSize` | functions | Persist settings window size. |
| `getLocked` / `setLocked` | functions | Persist whether the frame can be moved/resized. |
| `dashboard` | table/function | Dashboard hero, cards, status, feature lists. |
| `version` | function/string | Version text for status displays. |
| `isNewTag` | function | Returns whether a tag should show a new badge. |
| `iconTextures` | table | Map `iconKey` to texture path. |
| `categoryIconTextures` | table | Map category id to texture path. |
| `openLegacySettings` | function | Called by controls that should jump to Blizzard settings. |

## Categories

Categories are the top-level sidebar groupings.

```lua
app:RegisterCategory({
  id = "interface",
  title = INTERFACE_LABEL or "Interface",
  order = 100,
  iconAtlas = "hud-microbutton-character-up",
})
```

Fields:

| Field | Type | Purpose |
| --- | --- | --- |
| `id` | string | Stable category id. |
| `title` | string | Display label. |
| `order` | number | Sort order, then title. |
| `icon` | string | Texture path. |
| `iconAtlas` | string | Blizzard atlas. |
| `iconKey` | string | Lookup key in `categoryIconTextures` or `iconTextures`. |

## Pages

Pages contain groups and controls. They can either render settings controls or
an info layout.

```lua
app:RegisterPage({
  id = "interface.action-bars",
  category = "interface",
  title = "Action Bars",
  description = "Configure action bar behavior.",
  iconKey = "actionbar",
  mainToggleID = "actionBarsEnabled",
  newTagID = "ActionBars",
  order = 120,
})
```

Fields:

| Field | Type | Purpose |
| --- | --- | --- |
| `id` | string | Stable page id. |
| `category` | string | Parent category id. |
| `title` | string | Display title. |
| `description` | string | Page card/about text. |
| `icon`, `iconAtlas`, `iconKey` | string | Page icon source. |
| `mainToggleID` | string | Control id used as feature toggle for dashboard states. |
| `newTagID` | string | New badge tag. |
| `order` | number | Sort order. |
| `layout` | string | Use `"info"` for non-control content pages. |
| `content` | table/function | Blocks for info pages. |
| `visible`, `isVisible`, `visibleWhen` | boolean/function | Visibility gates. |
| `hidden`, `hiddenWhen` | boolean/function | Hide gates. |

### Info Page Example

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
        { type = "text", text = "Use these commands in chat." },
        { type = "spacer", height = 8 },
        {
          type = "button",
          text = "Copy Discord Invite",
          width = 220,
          onClick = function()
            -- Show your own copy-url popup here.
          end,
        },
      },
    },
  },
})
```

## Groups

Groups segment controls inside a page.

```lua
app:RegisterGroup("interface.action-bars", {
  id = "visibility",
  title = "Visibility",
  order = 200,
})
```

Controls can join a group with `groupID = "visibility"`. Legacy wrappers can
also pass `modernGroup`, `groupTitle`, and `groupOrder`.

## Controls

Controls are registered with `app:RegisterControl(pageID, data)`.

Core fields:

| Field | Type | Purpose |
| --- | --- | --- |
| `id` | string | Stable control id. Defaults to `key`/`var` when omitted. |
| `key` / `var` | string | DB key for default get/set behavior. |
| `type` | string | Widget type. |
| `label` / `text` / `name` | string | Display label. |
| `description` / `desc` | string | Inline description or compact tooltip/note text. |
| `default` | any/function | Reset/default comparison value. |
| `dbDefault` | any/function | Default provider used for DB-backed controls. |
| `getValue` / `get` | function | Explicit getter. |
| `setValue` / `set` | function | Explicit setter. |
| `isEnabled` | function | Disabled-state gate. |
| `parentCheck` | function | Parent/child enabled-state gate. |
| `visible`, `isVisible`, `visibleWhen` | boolean/function | Visibility gates. |
| `hidden`, `hiddenWhen` | boolean/function | Hide gates. |
| `keywords` / `searchtags` | string/table | Extra search text. |
| `newTagID` | string | New badge tag. |
| `order` | number | Sort order within the page/group. |
| `groupID` / `modernGroup` | string | Group assignment. |
| `trackCustomized` | boolean/function | Override customized-count behavior. |
| `refreshOnChange` | boolean | Re-render visible rows after change. |

### Toggle

```lua
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "Enabled",
  description = "Enable the feature.",
  default = true,
})
```

With explicit persistence:

```lua
app:RegisterControl("general.core", {
  id = "privateMode",
  type = "toggle",
  label = "Private mode",
  default = false,
  getValue = function()
    return MyAddon.PrivateDB.privateMode == true
  end,
  setValue = function(value)
    MyAddon.PrivateDB.privateMode = value == true
    MyAddon.RefreshPrivateMode()
  end,
})
```

### Slider

```lua
app:RegisterControl("interface.bars", {
  id = "barScale",
  key = "barScale",
  type = "slider",
  label = "Scale",
  description = "Adjust the bar size.",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  formatter = function(value)
    return string.format("%.0f%%", (tonumber(value) or 1) * 100)
  end,
})
```

### Dropdown

```lua
local anchorOrder = { "LEFT", "CENTER", "RIGHT" }
local anchorOptions = {
  LEFT = "Left",
  CENTER = "Center",
  RIGHT = "Right",
}

app:RegisterControl("interface.bars", {
  id = "barAnchor",
  key = "barAnchor",
  type = "dropdown",
  label = "Anchor",
  list = anchorOptions,
  orderList = anchorOrder,
  default = "CENTER",
})
```

Dynamic list:

```lua
app:RegisterControl("sounds.alerts", {
  id = "alertSound",
  key = "alertSound",
  type = "dropdown",
  label = "Alert sound",
  listFunc = function()
    return MyAddon.GetSoundOptions()
  end,
  optionfunc = function()
    return MyAddon.GetSoundOrder()
  end,
  menuHeight = 260,
  default = "",
})
```

### MultiDropdown

Use boolean-map selections. Selected keys should be `true`; deselected keys
should be removed or set to `nil`.

```lua
local options = {
  tank = "Tank",
  healer = "Healer",
  damage = "Damage",
}
local order = { "tank", "healer", "damage" }

app:RegisterControl("group.roles", {
  id = "enabledRoles",
  type = "multidropdown",
  label = "Roles",
  options = options,
  orderList = order,
  getSelection = function()
    return MyAddonDB.profile.enabledRoles or {}
  end,
  setSelection = function(selection)
    MyAddonDB.profile.enabledRoles = selection or {}
    MyAddon.RefreshRoleFilters()
  end,
  default = {},
})
```

Per-option callbacks:

```lua
app:RegisterControl("group.roles", {
  id = "enabledRoles",
  type = "multidropdown",
  label = "Roles",
  options = options,
  orderList = order,
  isSelectedFunc = function(value)
    local roles = MyAddonDB.profile.enabledRoles
    return roles and roles[value] == true
  end,
  setSelectedFunc = function(value, selected)
    MyAddonDB.profile.enabledRoles = MyAddonDB.profile.enabledRoles or {}
    MyAddonDB.profile.enabledRoles[value] = selected and true or nil
    MyAddon.RefreshRoleFilters()
  end,
})
```

Do not rebuild the settings window from `setSelectedFunc`; update config and
runtime previews only.

### Input

```lua
app:RegisterControl("general.names", {
  id = "profileName",
  key = "profileName",
  type = "input",
  label = "Profile name",
  placeholder = "Name",
  maxChars = 32,
  default = "",
})
```

Numeric input:

```lua
app:RegisterControl("timers.pull", {
  id = "pullSeconds",
  key = "pullSeconds",
  type = "input",
  label = "Pull timer",
  numeric = true,
  min = 3,
  max = 60,
  clampToRange = true,
  default = 10,
})
```

Multiline input:

```lua
app:RegisterControl("macros.text", {
  id = "macroBody",
  key = "macroBody",
  type = "input",
  label = "Macro body",
  multiline = true,
  multilineHeight = 120,
  inputWidth = 420,
  default = "",
})
```

### Button

```lua
app:RegisterControl("profiles.import", {
  id = "exportProfile",
  type = "button",
  label = "Export profile",
  buttonText = "Export",
  description = "Create an export string for the current profile.",
  onClick = function()
    MyAddon.ShowExportPopup()
  end,
})
```

### Color Picker

```lua
app:RegisterControl("bars.colors", {
  id = "barColor",
  key = "barColor",
  type = "colorpicker",
  label = "Bar color",
  hasOpacity = true,
  default = { r = 0.9, g = 0.2, b = 0.2, a = 1 },
  callback = function(color)
    MyAddon.ApplyBarColor(color)
  end,
})
```

### Color Overrides

```lua
app:RegisterControl("bars.colors", {
  id = "classColors",
  type = "coloroverrides",
  label = "Class colors",
  entries = {
    { key = "WARRIOR", label = "Warrior" },
    { key = "MAGE", label = "Mage" },
  },
  getColor = function(key)
    return MyAddonDB.profile.classColors[key]
  end,
  setColor = function(key, color)
    MyAddonDB.profile.classColors[key] = color
    MyAddon.RefreshClassColors()
  end,
  getDefaultColor = function(key)
    return MyAddon.DefaultClassColors[key]
  end,
})
```

### Sound Dropdown

```lua
app:RegisterControl("sounds.alerts", {
  id = "readySound",
  key = "readySound",
  type = "sounddropdown",
  label = "Ready sound",
  placeholderText = NONE or "None",
  menuHeight = 260,
  previewTooltip = "Preview this sound.",
  playbackChannel = "Master",
  soundResolver = function(value)
    return MyAddon.ResolveSound(value)
  end,
  previewSoundFunc = function(value)
    MyAddon.PlaySound(value)
  end,
})
```

### Checkbox Dropdown

Use this when one row has a primary checkbox plus an associated dropdown.

```lua
app:RegisterControl("alerts.threshold", {
  id = "healthAlert",
  key = "healthAlertEnabled",
  type = "checkboxdropdown",
  label = "Health alert",
  dropdownKey = "healthAlertThreshold",
  dropdownText = "Threshold",
  dropdownList = {
    LOW = "Low",
    MEDIUM = "Medium",
    HIGH = "High",
  },
  dropdownOrder = { "LOW", "MEDIUM", "HIGH" },
  default = false,
  dropdownDefault = "MEDIUM",
})
```

### Reorder List

Use this for ordered user-managed lists.

```lua
app:RegisterControl("bars.layout", {
  id = "barOrder",
  type = "reorderlist",
  label = "Bar order",
  rowHeight = 260,
  getEntries = function()
    return MyAddonDB.profile.barOrder or {}
  end,
  moveEntry = function(fromIndex, toIndex)
    MyAddon.MoveBarOrderEntry(fromIndex, toIndex)
  end,
  removeEntry = function(index)
    MyAddon.RemoveBarOrderEntry(index)
  end,
  setEntryFormat = function(index, formatKey)
    MyAddon.SetBarOrderFormat(index, formatKey)
  end,
  formatOptions = {
    icon = "Icon",
    text = "Text",
  },
  formatOrder = { "icon", "text" },
})
```

## Notes and Tooltips

Short descriptions can use `description`/`desc`. Longer hover notes can use
`note`, `notes`, `richNote`, or `richNotes`.

```lua
app:RegisterControl("dungeons.timer", {
  id = "mythicTimer",
  key = "mythicTimer",
  type = "toggle",
  label = "Mythic+ Timer",
  description = "Show timer controls in Mythic+ runs.",
  note = {
    title = "Details",
    text = "Configure layout, display, bars, fonts, colors, and behavior in Edit Mode.",
    order = 10,
  },
})
```

Rich note with image:

```lua
app:RegisterControl("interface.preview", {
  id = "previewMode",
  type = "toggle",
  label = "Preview mode",
  notes = {
    {
      title = "Preview",
      blocks = {
        { text = "Use preview mode to position frames before entering combat." },
        {
          image = "Interface\\AddOns\\MyAddon\\Media\\preview.tga",
          width = 256,
          height = 144,
        },
      },
    },
  },
})
```

Note fields:

| Field | Type | Purpose |
| --- | --- | --- |
| `title` | string | Optional note heading. |
| `text` | string | Body text. |
| `blocks` | table | Ordered text/image/spacer blocks. |
| `order` | number | Note order. |
| `visible` / `condition` | function | Conditional display. |
| `color` | table | Text color table. |
| `font` | string | Font object/template. |

Block types:

```lua
{ type = "spacer", height = 8 }
{ text = "Plain text." }
{ title = "Subheading", text = "Body text." }
{ image = "Interface\\AddOns\\MyAddon\\Media\\image.tga", width = 256, height = 144 }
```

## Dashboard

The dashboard can be static or generated each render.

```lua
local app = Config:RegisterAddOn("MyAddon", {
  dashboard = function(appInstance)
    return {
      hero = {
        title = "My Addon Settings",
        subtitle = "Configure core features and profiles.",
        iconKey = "dashboard",
      },
      cards = {
        {
          title = "Quick Reference",
          description = "Commands and usage notes.",
          iconKey = "help",
          pageID = "help.quick-reference",
        },
      },
      status = {
        title = STATUS or "Status",
        tiles = function(_, stats)
          return {
            {
              title = "Customized",
              value = tostring(stats.customized or 0),
              atlas = "worldquest-tracker-questmarker",
            },
          }
        end,
      },
      features = {
        enabledTitle = "Enabled features",
        customizedTitle = "Customized features",
        limit = 5,
      },
      newEntries = {
        title = "New in this version",
        limit = 5,
      },
    }
  end,
})
```

## Opening and Navigation

```lua
ConfigUI:Open(app)
ConfigUI:Open(app, "interface.action-bars")
ConfigUI:Open(app, "interface.action-bars", "barScale")
ConfigUI:Toggle(app)

local frame = ConfigUI:GetFrame(app)
```

`Open` also accepts the addon id:

```lua
ConfigUI:Open("MyAddon", "general.core")
```

If `pageID` contains `page.control`, `ResolveOpenTarget` can split the longest
matching page id and focus the remaining control id.

## Defaults, Customized Counts, and Reset

Controls are considered customized when the current value differs from the
resolved default.

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

Use explicit getters/setters for nested config, private DB tables, per-character
data, runtime-derived values, or compatibility fallbacks.

## Legacy Wrapper Bridge

An addon can expose wrapper functions such as `SettingsCreateCheckbox`,
`SettingsCreateDropdown`, and `SettingsCreateExpandableSection`. Those wrappers
can register Blizzard/legacy settings metadata and forward modern metadata into
LibSettingsDesigner via:

- `RegisterLegacyCategory`
- `RegisterLegacySection`
- `RegisterLegacyControl`

Feature modules should usually call the addon wrapper, not the raw lib.

Typical wrapper-side flow:

```lua
local app = ensureConfigApp()

app:RegisterLegacyCategory(category, {
  categoryID = "interface",
  title = INTERFACE_LABEL or "Interface",
})

app:RegisterLegacySection(section, {
  categoryID = "interface",
  pageID = "interface.action-bars",
  title = "Action Bars",
  description = "Configure action bars.",
  iconKey = "actionbar",
})

app:RegisterLegacyControl({
  parentSection = section,
  id = "actionBarMouseover",
  key = "actionBarMouseover",
  type = "toggle",
  label = "Mouseover",
  description = "Fade action bars until hovered.",
  default = false,
})
```

## Visibility and Enablement

Use visibility gates to remove a page/control from the UI:

```lua
visibleWhen = function(control, app)
  return MyAddon.HasFeature("advanced")
end
```

Use enabled gates to keep a row visible but disabled:

```lua
isEnabled = function(control, app)
  return MyAddonDB.profile.enabled == true
end
```

For child controls tied to a parent checkbox:

```lua
local function parentEnabled()
  return MyAddonDB.profile.parentFeature == true
end

app:RegisterControl("general.core", {
  id = "childOption",
  key = "childOption",
  type = "slider",
  label = "Child option",
  min = 1,
  max = 10,
  default = 5,
  parentCheck = parentEnabled,
})
```

## Search

Search text is built from:

- control label/title/text/id
- description
- key
- keywords/searchtags
- page title
- group title
- category title
- note title/text/blocks

Add search aliases with `keywords` or `searchtags`:

```lua
app:RegisterControl("interface.names", {
  id = "showNicknames",
  key = "showNicknames",
  type = "toggle",
  label = "Show nicknames",
  keywords = { "alias", "display name", "social" },
})
```

## New Badges

Set `newTagID` on pages or controls. Provide `opts.isNewTag(tagID)` on the app.

```lua
local app = Config:RegisterAddOn("MyAddon", {
  isNewTag = function(tagID)
    return MyAddon.NewTags and MyAddon.NewTags[tagID] == true
  end,
})

app:RegisterControl("general.core", {
  id = "freshFeature",
  key = "freshFeature",
  type = "toggle",
  label = "Fresh feature",
  newTagID = "FreshFeature",
})
```

## Asset Lookup

Use `icon`, `iconAtlas`, or `iconKey`.

```lua
local app = Config:RegisterAddOn("MyAddon", {
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  iconTextures = {
    dashboard = "Interface\\AddOns\\MyAddon\\Media\\dashboard.tga",
    actionbar = "Interface\\AddOns\\MyAddon\\Media\\actionbar.tga",
  },
})
```

Rules:

- Keep LibSettingsDesigner UI assets in the vendored lib folder.
- Keep addon-specific page/category icons in the addon media folder unless they
  are part of the reusable LibSettingsDesigner skin.
- Use stable `iconKey` names so pages can be registered before icon paths are
  finalized.

## Localization

LibSettingsDesigner does not own feature strings. The host addon owns all
labels, descriptions, notes, page titles, and button text.

Recommended pattern:

```lua
local L = LibStub("AceLocale-3.0"):GetLocale("MyAddon")

app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = L["enabled"],
  description = L["enabledDesc"],
})
```

## Wrapper Bridge Pattern

Addons can wrap LibSettingsDesigner behind their own settings helpers. This is
useful when the addon needs to register legacy settings metadata and modern
settings metadata from one call.

```lua
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local section = addon.SettingsCreateExpandableSection(category, {
  name = L["myFeature"],
  description = L["myFeatureDesc"],
  configPageID = "interface.my-feature",
  iconKey = "settingspage",
  newTagID = "MyFeature",
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

## Do and Do Not

Do:

- Use stable ids for categories, pages, groups, and controls.
- Use explicit `get`/`set` for anything that is not a simple DB key.
- Keep `set` callbacks focused on data changes and runtime refreshes.
- Use `order` or `orderList` for deterministic display.
- Use `notes` for long explanations and `description` for short summaries.
- Persist window size/lock through app options when desired.
- Keep the library vendored per addon.
- Update `AGENTS.md`, `SKILL.md`, and navigation sidebars when public docs/workflows change.

Do not:

- Ship the lib as a standalone shared LibStub package.
- Depend on another addon loading the library first.
- Rebuild the settings frame from MultiDropdown selection callbacks.
- Add feature strings inside the library.
- Use unstable display text as ids when a stable key exists.
- Claim docs were verified against code when source files were not available.
- Put addon-specific feature logic inside `LibSettingsDesignerUI.lua`.

## Minimal Smoke Test

After changing the library:

```bash
lua -e 'assert(loadfile("MyAddon/libs/LibSettingsDesigner/LibSettingsDesignerConfig.lua"))'
lua -e 'assert(loadfile("MyAddon/libs/LibSettingsDesigner/LibSettingsDesignerUI.lua"))'
luacheck MyAddon/libs/LibSettingsDesigner/LibSettingsDesignerConfig.lua MyAddon/libs/LibSettingsDesigner/LibSettingsDesignerUI.lua
```

For in-game validation:

1. Open the settings center.
2. Verify dashboard, sidebar, page cards, and search render.
3. Open pages containing toggles, sliders, dropdowns, MultiDropdowns, inputs,
   color pickers, sound dropdowns, and notes.
4. Change a value and verify DB persistence and runtime refresh.
5. Reset a page and verify values return to defaults.
6. Hover controls with notes and verify tooltip spacing and text wrapping.
