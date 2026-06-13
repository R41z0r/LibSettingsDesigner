<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Goal](#goal)
- [1. Load the Library](#1-load-the-library)
- [2. Create the App](#2-create-the-app)
- [3. Register Structure](#3-register-structure)
- [4. Register Controls](#4-register-controls)
- [5. Open the UI](#5-open-the-ui)
- [6. Test It](#6-test-it)
- [Next Reading](#next-reading)

</details>

## [Goal][Top]

This page creates the smallest useful LibSettingsDesigner integration:

- one app
- one category
- one page
- one group
- one toggle
- one slider
- one slash command to open the UI

For a larger sample, see [Complete Settings Center](Examples/Complete-Settings-Center.md).

## [1. Load the Library][Top]

Host addon layout:

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

TOC:

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
Settings.lua
```

`LibSettingsDesigner.xml` must load before `Settings.lua`.

## [2. Create the App][Top]

```lua
local addonName, addon = ...
local Designer = addon.LibSettingsDesigner
local Config = Designer and Designer.Config
local ConfigUI = Designer and Designer.UI

if not Config or not ConfigUI then
  return
end

MyAddonDB = MyAddonDB or {}
MyAddonDB.profile = MyAddonDB.profile or {}

local function DB()
  MyAddonDB.profile.enabled = MyAddonDB.profile.enabled ~= false
  MyAddonDB.profile.scale = MyAddonDB.profile.scale or 1
  return MyAddonDB.profile
end

local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  settingsTitle = "My Addon Settings",
  dashboardTitle = "Dashboard",
  addonFolder = addonName,
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  density = "compact",
  db = DB,
  locale = addon.L,
})
```

## [3. Register Structure][Top]

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
  mainToggleID = "enabled",
})

app:RegisterGroup("general.core", {
  id = "behavior",
  title = "Behavior",
  order = 100,
})
```

## [4. Register Controls][Top]

Simple DB-backed toggle:

```lua
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  groupID = "behavior",
  type = "toggle",
  label = ENABLE or "Enable",
  description = "Enable the addon.",
  default = true,
})
```

Slider with a runtime refresh callback:

```lua
app:RegisterControl("general.core", {
  id = "scale",
  key = "scale",
  groupID = "behavior",
  type = "slider",
  label = "Scale",
  description = "Adjust the main UI scale.",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  parentCheck = function()
    return DB().enabled == true
  end,
  formatter = function(value)
    return string.format("%.0f%%", (tonumber(value) or 1) * 100)
  end,
  setValue = function(value)
    DB().scale = tonumber(value) or 1
    if addon.RefreshScale then
      addon.RefreshScale()
    end
  end,
})
```

## [5. Open the UI][Top]

```lua
SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function(input)
  input = strtrim(input or "")

  if input == "core" then
    ConfigUI:Open(app, "general.core")
    return
  end

  ConfigUI:Toggle(app)
end
```

Direct navigation examples:

```lua
ConfigUI:Open(app)
ConfigUI:Open(app, "general.core")
ConfigUI:Open(app, "general.core", "scale")
```

## [6. Test It][Top]

1. `/reload`
2. Run `/myaddon`.
3. Confirm the settings window opens.
4. Change the toggle and slider.
5. `/reload` again and confirm values persisted.
6. Search for `scale`.
7. Reset the page and confirm defaults return.

## [Next Reading][Top]

- [Architecture](Architecture.md)
- [Field Glossary](Field-Glossary.md)
- [Config API](API/Config-API.md)
- [UI API](API/UI-API.md)
- [Elements](Elements/Elements.md)
- [Complete Settings Center](Examples/Complete-Settings-Center.md)
- [Troubleshooting](Troubleshooting.md)

[//]: # (Links)
[Top]: #Top
