<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [TOC](#toc)
- [Lua](#lua)
- [Open Command](#open-command)

</details>

## [TOC][Top]

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
Core.lua
Settings.lua
```

## [Lua][Top]

```lua
local addonName, addon = ...
local Designer = addon.LibSettingsDesigner
local Config = Designer.Config
local ConfigUI = Designer.UI

local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  settingsTitle = "My Addon Settings",
  addonFolder = addonName,
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  db = function() return MyAddonDB.profile end,
})

app:RegisterCategory({ id = "general", title = GENERAL or "General", order = 100 })
app:RegisterPage({ id = "general.core", category = "general", title = "Core", order = 100 })
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = ENABLE or "Enable",
  default = true,
})
```

## [Open Command][Top]

```lua
SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function()
  ConfigUI:Open(app)
end
```

[//]: # (Links)
[Top]: #Top

