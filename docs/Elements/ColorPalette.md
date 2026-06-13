<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Preview](#preview)
- [Fields](#fields)
- [Example](#example)
- [Legacy Alias](#legacy-alias)

</details>

## [Overview][Top]

ColorPalette manages multiple keyed color values in one row. Use it for role
colors, class colors, border colors, status colors, or other small named color
sets owned by the host addon.

Use `type = "colorpalette"` for new code.

## [Preview][Top]

![ColorPalette example](../assets/images/color-overrides-example.png)

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `entries` | table | List of `{ key, label }` color entries. |
| `getColor` | function | Reads current color by key. |
| `setColor` | function | Writes color by key. |
| `hasOpacity` | boolean | Show alpha channel. |
| `colorizeLabel` | boolean | Tint entry labels with current colors. |

`getDefaultColor` is currently metadata/pass-through only and is not consumed by
the UI renderer.

## [Example][Top]

```lua
app:RegisterControl("bars.colors", {
  id = "classColors",
  type = "colorpalette",
  label = "Class colors",
  entries = {
    { key = "WARRIOR", label = "Warrior" },
    { key = "MAGE", label = "Mage" },
  },
  getColor = function(key)
    return MyAddonDB.profile.classColors[key]
  end,
  setColor = function(key, r, g, b, a)
    MyAddonDB.profile.classColors[key] = { r = r, g = g, b = b, a = a or 1 }
    MyAddon.RefreshClassColors()
  end,
})
```

## [Legacy Alias][Top]

`type = "coloroverrides"` and `type = "coloroverride"` are legacy aliases for
`type = "colorpalette"`. They still render the same widget for older host
addons, but new code and documentation should use `colorpalette`.

[//]: # (Links)
[Top]: #Top
