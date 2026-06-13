<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Expandable Section Helper](#expandable-section-helper)
- [Control Helper](#control-helper)
- [Rules](#rules)

</details>

## [Overview][Top]

Addons can expose their own `SettingsCreate*` helpers and keep feature modules
away from raw LibSettingsDesigner calls. The helper layer can register legacy
settings metadata, modern page metadata, defaults, locale text, and runtime
callbacks from one call.

## [Expandable Section Helper][Top]

```lua
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local section = addon.SettingsCreateExpandableSection(category, {
  name = L["myFeature"],
  description = L["myFeatureDesc"],
  configPageID = "interface.my-feature",
  iconKey = "settingspage",
  newTagID = "MyFeature",
  expanded = false,
  colorizeTitle = false,
})
```

The helper can internally call:

```lua
app:RegisterLegacySection(section, {
  categoryID = "interface",
  pageID = data.configPageID,
  title = data.name,
  description = data.description,
  iconKey = data.iconKey,
  newTagID = data.newTagID,
})
```

## [Control Helper][Top]

```lua
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

The helper can internally call:

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

## [Rules][Top]

- Keep wrapper helpers thin and predictable.
- Feature modules should use the wrapper layer when one exists.
- Keep user-facing strings in the host addon's locale system.
- Keep setters focused on persistence and runtime refresh.
- Do not rebuild open dropdown or MultiDropdown menus from selection callbacks.

[//]: # (Links)
[Top]: #Top

