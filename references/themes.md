# Themes

Read only the sections relevant to the requested change. Paths in code examples
are relative to the library or host checkout as indicated. `docs/` paths refer
to the skill root documentation. This reference does not authorize external
actions or reading repository instructions outside the active project.

## Theme Colors

Use `opts.colors`, `opts.colorTable`, or `opts.themeColors` to override global
LibSettingsDesigner chrome colors. Every key is optional and falls back to the
built-in default when omitted.

Use this for UI shell colors such as background, overlay, buttons, rows, cards,
search, text, and accent. Do not use it for host-addon feature colors; those
belong to the host addon's own settings and saved variables.

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  colors = {
    background = { 0.02, 0.02, 0.025, 0.96 },
    overlay = { 0.75, 0.82, 0.95, 1 },
    accent = { 1.00, 0.82, 0.36, 1 },
    button = { 0.08, 0.07, 0.05, 0.94 },
    buttonHover = { 0.16, 0.12, 0.06, 0.98 },
    searchBorder = { 0.55, 0.44, 0.24, 0.90 },
  },
})
```

Color values may be array-shaped `{ r, g, b, a }` or named
`{ r = r, g = g, b = b, a = a }` tables. Dynamic themes may provide
`colors = function(app) return colorTable end`.

Common semantic keys:

```text
background, overlay, panel, content, sidebar, card, cardHover, cardBorder,
cardHoverBorder, row, rowBorder, rowHover, rowHoverBorder, tabPanel,
tabPanelBorder, tab, tabHover, tabSelected, tabText, tabSelectedText,
tabUnderline, button, buttonBorder, buttonHover, buttonHoverBorder, search,
searchBorder, searchHighlight, searchResult, searchResultBorder, searchResultHover, searchResultHoverBorder,
dropdown, dropdownBorder, dropdownHover, dropdownHoverBorder,
input, inputBorder, inputFocus, inputFocusBorder, selected, text, mutedText,
subtleText, disabledText, accent, topbarText
```

`colors.searchHighlight` controls the brief target-row flash after selecting a
search result. Direct `UI:Open(app, pageID, controlID)` links only scroll; they
do not flash. Only search navigation opts into the internal highlight flag.
It is independent of `accent` and search-result card hover colors. The default
is `{ 1, 0.72, 0.12, 0.32 }` (gold); e.g. use
`searchHighlight = { 0.2, 0.75, 1, 0.4 }` for cyan. Named RGBA values and dynamic
theme functions work through the existing theme resolver. Alpha controls peak
opacity; alpha `0` hides the flash while retaining scroll-to-control behavior.
The row flashes twice over 1.45 seconds after layout/scrolling. Page-only links
do not flash; content refresh/navigation and window hide cancel the animation
and pending focus. Resolve the color for the target app on every flash, including
reused rows. Acknowledge programmatic search changes by their expected text value:
`OnTextChanged` may run after `SetText` returns, so a synchronous suppression flag
alone can rebuild the page and cancel the pending highlight. See
`docs/Examples/Theme-Colors.md` and `docs/API/UI-API.md`.

For precise one-off overrides, use direct detail keys such as `topbarBg`,
`topbarBorder`, `buttonTopbarBg`, `dashboardCardBg`, `detailSectionBg`,
`disabledControlBg`, or any other key documented in
`docs/Examples/Theme-Colors.md`.

## Theme Borders

Use `opts.borders`, `opts.themeBorders`, or `opts.borderAssets` to override
global LibSettingsDesigner backdrop border assets. Every key is optional and
falls back to the built-in default when omitted.

Keep this separate from `colors`: colors define RGBA values, borders define
backdrop files, edge sizes, tile settings, and insets.

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
  },
})
```

Common border keys:

```text
default, panel, topbar, content, sidebar, card, dashboardCard, detailSection,
detailColumn, row, button, topbarButton, search, control, toggle, toggleKnob,
searchResult, swatch, reorderItem, dropdownControl, inputControl, statusChip
```

The decorative outer frame is configured separately with `borders.window`,
`borders.windowBorder`, `borders.outerBorder`, or `borders.frameBorder`. It uses
slice textures such as `PanelBorder_tl.tga` and supports `prefix`, `suffix`,
`files`, `cornerSize`, `edgeThickness`, `cornerOffset`, `rightOffset`, `color`,
`alpha`, and `enabled = false`.

Dynamic border themes may provide
`borders = function(app) return borderTable end`. Detailed border keys and
aliases are documented in `docs/Examples/Theme-Borders.md`.

Use `borders.default = false` when a theme should suppress normal backdrop
borders. Use `themeTextures`, `textureBorders`, or `shapeTextures` for
non-backdrop shape art such as a superellipse texture. Texture styles use the
same keys as border styles and may set `replaceBackdrop = true` when the shape
should replace the normal rectangular backdrop fill.

`dropdownControl`, `inputControl`, and `statusChip` are dedicated opt-in shape
slots. Existing `dropdown` and `input` border aliases still resolve to
`button` and `control` for backward compatibility. A full-shape texture is not
an outline mask; set `borderAlpha = 0` when it should render as a single fill
instead of stacking a second full-shape border layer.

Use `windowBorder = false` when a host theme should hide the packaged outer
window art frame. Detailed shape texture examples are documented in
`docs/Examples/Theme-Borders.md`.
