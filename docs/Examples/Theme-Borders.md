<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Recommended Pattern](#recommended-pattern)
- [Example](#example)
- [Border Keys](#border-keys)
- [Rules](#rules)

</details>

## [Overview][Top]

Host addons can override LibSettingsDesigner backdrop border assets with
`opts.borders`, `opts.themeBorders`, or `opts.borderAssets` in
`Config:RegisterAddOn`.

Every key is optional. Missing keys keep the built-in LibSettingsDesigner
default. Use `default` when one asset should apply broadly, then override
individual zones such as `button`, `row`, `topbar`, or `search`.

Border styles use the standard WoW backdrop fields:

```lua
{
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\AddOns\\MyAddon\\Media\\MyBorder",
  tile = true,
  tileSize = 16,
  edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}
```

## [Recommended Pattern][Top]

Use one default and override only the zones that should visibly differ:

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  borders = {
    default = {
      edgeFile = "Interface\\AddOns\\MyAddon\\Media\\PanelBorder",
      edgeSize = 14,
      insets = { left = 4, right = 4, top = 4, bottom = 4 },
    },
    button = {
      edgeFile = "Interface\\AddOns\\MyAddon\\Media\\ButtonBorder",
      edgeSize = 10,
      insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    toggle = {
      edgeFile = "Interface\\AddOns\\MyAddon\\Media\\ToggleBorder",
      edgeSize = 9,
      insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
    window = {
      prefix = "Interface\\AddOns\\MyAddon\\Media\\OuterBorder_",
      cornerSize = 44,
      edgeThickness = 44,
      cornerOffset = 8,
      rightOffset = 10,
      color = { 0.00, 0.72, 0.92, 0.90 },
      alpha = 0.90,
    },
  },
})
```

For dynamic themes, provide a function:

```lua
borders = function(app)
  return MyAddonDB.profile.theme == "custom" and MyAddon.CustomBorders or nil
end
```

If the options are changed after the frame was created, open the settings again
or call `ConfigUI:Open(app)` to refresh the visible frame theme.

## [Example][Top]

```lua
local MY_BORDERS = {
  default = {
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  },
  row = {
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  },
  topbarButton = {
    edgeFile = "Interface\\AddOns\\MyAddon\\Media\\TopbarButtonBorder",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  },
}

local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  borders = MY_BORDERS,
})
```

## [Border Keys][Top]

Direct keys:

```text
default, panel, topbar, content, sidebar, card, dashboardCard, detailSection,
detailColumn, row, button, topbarButton, search, control, toggle, toggleKnob,
swatch, reorderItem
```

The outer decorative frame uses a separate sliced texture config under
`window`, `windowBorder`, `outerBorder`, or `frameBorder`. It expects textures
named with the suffixes `tl`, `tr`, `bl`, `br`, `t`, `b`, `l`, and `r` when
using `prefix`, such as `OuterBorder_tl.tga`. Supported fields are:

| Field | Use |
| :---- | :-- |
| `prefix` / `texturePrefix` / `filePrefix` / `path` | Texture prefix before the slice suffix. Defaults to the vendored `PanelBorder_` assets. |
| `suffix` / `extension` | Texture suffix. Defaults to `.tga`. |
| `files` | Optional per-slice texture map keyed by `tl`, `tr`, `bl`, `br`, `t`, `b`, `l`, and `r`. |
| `cornerSize` | Width and height for corner slices. |
| `edgeThickness` / `edgeSize` / `thickness` | Thickness for edge slices. |
| `cornerOffset` / `offset` | Offset of the decorative border outside the frame. |
| `rightOffset` | Right-side offset override. |
| `color` / `tint` / `vertexColor` | Vertex color for the border textures. |
| `alpha` | Border alpha. |
| `enabled = false` | Hides the decorative window border. |

Aliases:

```text
background -> panel
frame -> panel
buttons -> button
topbarButtons -> topbarButton
checkbox / checkboxes / switch -> toggle
switchKnob -> toggleKnob
dropdown -> button
input -> control
color / colorSwatch -> swatch
dashboard -> dashboardCard
detail -> detailSection
```

## [Rules][Top]

- Keep `colors` and `borders` separate.
- Use `colors` for RGBA values.
- Use `borders` for backdrop assets, edge size, tile settings, and insets.
- Use addon's own media paths for custom assets.
- Override only what the addon needs; defaults remain for missing keys.

[//]: # (Links)
[Top]: #Top
