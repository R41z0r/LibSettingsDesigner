<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)

</details>

## [Overview][Top]

ColorOverrides manages multiple keyed color values in one row.

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
})
```

[//]: # (Links)
[Top]: #Top
