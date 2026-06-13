<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [What This Sample Shows](#what-this-sample-shows)
- [TOC](#toc)
- [Saved Variables](#saved-variables)
- [Settings Registration](#settings-registration)
- [Slash Command](#slash-command)
- [What to Copy](#what-to-copy)

</details>

## [What This Sample Shows][Top]

This is a compact but realistic end-to-end settings center. It demonstrates:

- vendored library loading
- app registration
- dashboard metadata
- categories, pages, groups, controls
- simple DB-backed controls
- explicit getter/setter controls
- notes
- search aliases
- a direct open slash command

It is intentionally generic. Replace `MyAddon`, `MyAddonDB`, and feature names
with your host addon names.

## [TOC][Top]

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
Core.lua
Settings.lua
```

The library XML must load before `Settings.lua`.

## [Saved Variables][Top]

```lua
MyAddonDB = MyAddonDB or {}
MyAddonDB.profile = MyAddonDB.profile or {
  enabled = true,
  scale = 1,
  anchor = "CENTER",
  roles = {
    damage = true,
  },
  window = {
    locked = false,
  },
}
```

## [Settings Registration][Top]

```lua
local addonName, addon = ...
local L = addon.L or {}

local Designer = addon.LibSettingsDesigner
local Config = Designer and Designer.Config
local ConfigUI = Designer and Designer.UI

if not Config or not ConfigUI then
  return
end

local function DB()
  MyAddonDB = MyAddonDB or {}
  MyAddonDB.profile = MyAddonDB.profile or {}
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
  locale = L,
  version = function()
    return C_AddOns and C_AddOns.GetAddOnMetadata(addonName, "Version") or nil
  end,
  isNewTag = function(tagID)
    return MyAddonNewTags and MyAddonNewTags[tagID] == true
  end,
  dashboard = function(_, stats)
    return {
      hero = {
        title = "My Addon Settings",
        subtitle = "Configure behavior, layout, profiles, and help pages.",
        iconKey = "dashboard",
      },
      cards = {
        {
          title = "Core",
          description = "Enable the addon and configure general behavior.",
          iconKey = "settingspage",
          pageID = "general.core",
        },
        {
          title = "Quick Reference",
          description = "Commands and support notes.",
          iconKey = "help",
          pageID = "help.quick-reference",
        },
      },
      status = {
        title = STATUS or "Status",
        tiles = {
          {
            title = "Customized",
            value = tostring(stats and stats.customized or 0),
            atlas = "worldquest-tracker-questmarker",
          },
        },
      },
    }
  end,
})

app:RegisterCategory({
  id = "general",
  title = GENERAL or "General",
  order = 100,
  iconAtlas = "communities-icon-chat",
})

app:RegisterCategory({
  id = "help",
  title = HELP_LABEL or "Help",
  order = 900,
  iconAtlas = "QuestNormal",
})

app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "Core",
  description = "Main addon behavior and layout.",
  iconKey = "settingspage",
  mainToggleID = "enabled",
  newTagID = "CorePage",
  order = 100,
})

app:RegisterGroup("general.core", {
  id = "behavior",
  title = "Behavior",
  order = 100,
})

app:RegisterGroup("general.core", {
  id = "layout",
  title = "Layout",
  order = 200,
})

app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  groupID = "behavior",
  type = "toggle",
  label = ENABLE or "Enable",
  description = "Enable the addon.",
  keywords = { "on", "off", "master switch" },
  default = true,
})

app:RegisterControl("general.core", {
  id = "scale",
  key = "scale",
  groupID = "layout",
  type = "slider",
  label = "Scale",
  description = "Adjust the main frame scale.",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  formatter = function(value)
    return string.format("%.0f%%", (tonumber(value) or 1) * 100)
  end,
  parentCheck = function()
    return DB().enabled == true
  end,
  setValue = function(value)
    DB().scale = tonumber(value) or 1
    if addon.RefreshScale then
      addon.RefreshScale()
    end
  end,
})

app:RegisterControl("general.core", {
  id = "anchor",
  key = "anchor",
  groupID = "layout",
  type = "dropdown",
  label = "Anchor",
  description = "Choose where the frame anchors by default.",
  list = {
    LEFT = "Left",
    CENTER = "Center",
    RIGHT = "Right",
  },
  orderList = { "LEFT", "CENTER", "RIGHT" },
  default = "CENTER",
})

app:RegisterControl("general.core", {
  id = "roles",
  groupID = "behavior",
  type = "multidropdown",
  label = "Roles",
  description = "Choose which roles should use this feature.",
  options = {
    tank = "Tank",
    healer = "Healer",
    damage = "Damage",
  },
  orderList = { "tank", "healer", "damage" },
  getSelection = function()
    DB().roles = DB().roles or {}
    return DB().roles
  end,
  setSelectedFunc = function(value, selected)
    DB().roles = DB().roles or {}
    DB().roles[value] = selected and true or nil
    if addon.RefreshRoles then
      addon.RefreshRoles()
    end
  end,
  default = {},
})

app:RegisterControlNote("scale", {
  title = "Scale tip",
  text = "Use smaller steps for pixel-sensitive UI elements. Test after /reload.",
  order = 10,
})

app:RegisterPage({
  id = "help.quick-reference",
  category = "help",
  title = "Quick Reference",
  description = "Slash commands and support notes.",
  layout = "info",
  order = 100,
  content = {
    {
      title = "Slash Commands",
      entries = {
        { type = "command", commands = { "/myaddon" }, desc = "Open settings." },
        { type = "command", commands = { "/myaddon reset" }, desc = "Reset profile." },
      },
    },
    {
      title = "Support",
      entries = {
        { type = "text", text = "When reporting issues, include addon version, WoW version, and reproduction steps." },
      },
    },
  },
})
```

## [Slash Command][Top]

```lua
SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function(input)
  input = strtrim(input or "")

  if input == "core" then
    ConfigUI:Open(app, "general.core")
    return
  end

  ConfigUI:Open(app)
end
```

## [What to Copy][Top]

For a real addon, copy the shape, not the exact names:

- Keep the `DB()` helper nil-safe.
- Keep `assetRoot` pointed at the host addon's vendored library folder.
- Use stable ids, not localized labels.
- Use direct `key` values for simple profile settings.
- Use explicit getters/setters for nested settings or runtime refresh.
- Add `keywords` for old option names and user search terms.
- Put long explanations in notes or info pages instead of huge row descriptions.

[//]: # (Links)
[Top]: #Top
