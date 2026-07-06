<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [App Chrome](#app-chrome)
- [Tabbed Category](#tabbed-category)
- [Full-Width Two-Column Page](#full-width-two-column-page)
- [Mixed Control Panel](#mixed-control-panel)
- [Row Actions](#row-actions)
- [Common Mistakes](#common-mistakes)

</details>

## [Overview][Top]

Use flexible layouts when a settings page would feel too dense in the default
left-column plus right-info-panel layout.

This pattern combines:

- compact sidebar rows and section headings
- category page tabs with an optional translucent tab panel
- full-width pages by disabling the right info panel
- side-by-side group sections
- mixed control columns inside one group
- small per-setting action menus

## [App Chrome][Top]

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  db = DB,
  sidebar = {
    rowHeight = 34,
    dashboardHeight = 38,
    sectionHeight = 24,
    iconSize = 16,
  },
  colors = function()
    return {
      tabPanel = MyAddonDB.profile.tabPanelColor or { 0.03, 0.04, 0.05, 0.62 },
      tabPanelBorder = { 0.42, 0.36, 0.22, 0.48 },
      tabSelected = MyAddonDB.profile.tabSelectedColor or { 0.00, 0.28, 0.24, 0.36 },
    }
  end,
})
```

The color function can read SavedVariables, so the host addon can expose its own
theme color settings without storing those values in LibSettingsDesigner.

## [Tabbed Category][Top]

```lua
app:RegisterCategory({
  id = "nameplates",
  title = "Nameplates",
  sidebarSection = "Unit Frames",
  tabView = {
    enabled = true,
    panel = {
      bg = { 0.00, 0.03, 0.04, 0.38 },
      border = { 0.00, 0.58, 0.72, 0.45 },
      texture = "Interface\\AddOns\\MyAddon\\Media\\Glows\\teal_horizontal_glow",
      textureAlpha = 0.82,
      textureBlendMode = "ADD",
    },
    defaultPageID = "nameplates.general",
    remember = true,
    gap = 14,
    paddingX = 10,
    underlineHeight = 3,
  },
  order = 200,
})
```

`panel = true` uses the global tab panel theme colors. Use a panel table for a
one-off tab-strip style or a packaged glow texture behind the tab buttons.

## [Full-Width Two-Column Page][Top]

```lua
app:RegisterPage({
  id = "nameplates.general",
  category = "nameplates",
  title = "General",
  description = "Customize nameplate appearance and behavior.",
  sidePanel = false,
  groupColumns = 2,
  groupColumnGap = 14,
  order = 100,
})

app:RegisterGroup("nameplates.general", {
  id = "style",
  title = "Style",
  column = 1,
  order = 100,
})

app:RegisterGroup("nameplates.general", {
  id = "text",
  title = "Text Positions",
  column = 2,
  order = 200,
})
```

`sidePanel = false` removes the right info/navigation panel. `groupColumns = 2`
then lets the page place group sections side by side.

## [Mixed Control Panel][Top]

```lua
app:RegisterGroup("nameplates.general", {
  id = "visibility",
  title = "Visibility",
  columns = 2,
  columnGap = 12,
  order = 300,
})

app:RegisterControl("nameplates.general", {
  id = "showFriendly",
  key = "showFriendly",
  groupID = "visibility",
  column = 1,
  type = "toggle",
  label = "Show Friendly Players",
  default = true,
  order = 100,
})

app:RegisterControl("nameplates.general", {
  id = "maxDistance",
  key = "maxDistance",
  groupID = "visibility",
  column = 2,
  type = "slider",
  label = "Max Distance",
  min = 10,
  max = 100,
  step = 5,
  default = 60,
  order = 110,
})
```

Controls without `column` flow into the shorter control column. Use explicit
columns when toggles and sliders should stay in predictable lanes.

## [Row Actions][Top]

```lua
app:RegisterControl("nameplates.general", {
  id = "plateWidth",
  key = "plateWidth",
  groupID = "style",
  type = "slider",
  label = "Plate Width",
  min = 80,
  max = 260,
  step = 5,
  default = 180,
  actions = {
    {
      id = "plateWidthTools",
      icon = "Interface\\Icons\\INV_Misc_Gear_01",
      tooltip = "Plate width tools",
      menu = {
        { text = "Set compact width", onClick = function() MyAddon.SetPlateWidth(140) end },
        { text = "Set wide width", onClick = function() MyAddon.SetPlateWidth(220) end },
      },
    },
  },
})
```

Row actions are UI chrome. Keep the actual feature behavior in host-addon
callbacks.

## [Common Mistakes][Top]

- Do not disable the right panel and keep `showSubnav = true`; subnavigation
  only renders inside the right panel.
- Do not use localized labels as `id`, `groupID`, or `column` data.
- Do not put host-addon feature strings into the generic runtime.
- Do not rebuild the settings frame from dropdown or MultiDropdown callbacks.

[//]: # (Links)
[Top]: #Top
