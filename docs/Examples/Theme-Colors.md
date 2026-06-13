<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Recommended Pattern](#recommended-pattern)
- [Example](#example)
- [Color Keys](#color-keys)
- [Rules](#rules)

</details>

## [Overview][Top]

Host addons can override LibSettingsDesigner UI colors with `opts.colors`,
`opts.colorTable`, or `opts.themeColors` in `Config:RegisterAddOn`.

Every key is optional. Missing keys keep the built-in LibSettingsDesigner
default. This makes small targeted changes safe, such as changing only the
accent color, button hover color, or main background.

Colors may use array or named table shape:

```lua
{ 1, 0.82, 0.36, 1 }
{ r = 1, g = 0.82, b = 0.36, a = 1 }
```

## [Recommended Pattern][Top]

Use semantic keys for most host addons:

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  colors = {
    background = { 0.02, 0.02, 0.025, 0.96 },
    overlay = { 0.75, 0.82, 0.95, 1 },
    accent = { 0.95, 0.72, 0.30, 1 },
    button = { 0.08, 0.07, 0.05, 0.94 },
    buttonHover = { 0.16, 0.12, 0.06, 0.98 },
    searchBorder = { 0.55, 0.44, 0.24, 0.90 },
  },
})
```

For dynamic themes, provide a function:

```lua
colors = function(app)
  return MyAddonDB.profile.darkTheme and MyAddon.DarkColors or MyAddon.LightColors
end
```

If the options are changed after the frame was created, open the settings again
or call `ConfigUI:Open(app)` to refresh the visible frame theme.

## [Example][Top]

```lua
local MY_COLORS = {
  background = { 0.018, 0.020, 0.024, 0.98 },
  panelBorder = { 0.45, 0.36, 0.22, 0.60 },
  row = { 0.05, 0.055, 0.060, 0.50 },
  rowHover = { 0.13, 0.10, 0.055, 0.62 },
  card = { 0.06, 0.064, 0.070, 0.92 },
  cardHover = { 0.13, 0.10, 0.055, 0.96 },
  button = { 0.08, 0.07, 0.05, 0.94 },
  buttonHover = { 0.18, 0.13, 0.06, 0.98 },
  accent = { 1.00, 0.82, 0.36, 1 },
  text = { 0.94, 0.91, 0.84, 1 },
}

local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  colors = MY_COLORS,
})
```

## [Color Keys][Top]

Semantic keys:

| Key | Affects |
| :-- | :------ |
| `background` | Outer frame background. |
| `overlay` | Background material tint. |
| `panel` / `content` | Content panel background. |
| `sidebar` | Sidebar panel background. |
| `card`, `cardHover`, `cardBorder`, `cardHoverBorder` | Cards and card hover state. |
| `row`, `rowBorder`, `rowHover`, `rowHoverBorder` | Setting rows and hover state. |
| `button`, `buttonBorder`, `buttonHover`, `buttonHoverBorder` | Standard flat buttons. |
| `search`, `searchBorder` | Search box shell. |
| `selected` | Selected button/card state. |
| `text`, `mutedText`, `subtleText`, `disabledText` | Text colors. |
| `accent` | Gold/accent color used by arrows, resize grip, and badges. |
| `topbarText` | Top bar title/button text. |

Direct detail keys are also accepted for precise control:

```text
panelBorder, topbarBg, topbarBorder, contentBg, cardBg, cardBgHover,
cardBorder, cardBorderHover, dashboardCardBg, dashboardCardBgHover,
dashboardCardBorder, detailSectionBg, detailColumnBg, detailColumnBorder,
detailSectionBorder, detailSectionHeaderBg, rowBg, rowBorder, rowHoverBg,
rowHoverBorder, rowSeparator, selectedBg, sidebarBg, frameBg, overlayTint,
buttonBg, buttonBorder, buttonHoverBg, buttonHoverBorder, buttonTopbarBg,
buttonTopbarBorder, buttonTopbarHoverBg, searchBg, searchBorder,
disabledControlBg, disabledControlBorder, disabledRowBg, disabledRowBorder,
textMain, textMuted, textSubtle, textDisabled, topbarAccent, success
```

## [Rules][Top]

- Keep feature-specific color settings in the host addon.
- Use `opts.colors` only for global LibSettingsDesigner chrome/theme colors.
- Do not store theme data in the generic library runtime.
- Override only what the addon needs; defaults remain for missing keys.

[//]: # (Links)
[Top]: #Top
