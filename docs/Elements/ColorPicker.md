<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)

</details>

## [Overview][Top]

A ColorPicker stores one `{ r, g, b, a }` color table.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `getColor` | function | Reads current color as `r, g, b, a`. |
| `setColor` | function | Writes current color. |
| `hasOpacity` | boolean | Show alpha channel. |
| `default` | table | Default color. |

## [Example][Top]

```lua
app:RegisterControl("bars.colors", {
  id = "barColor",
  key = "barColor",
  type = "colorpicker",
  label = "Bar color",
  hasOpacity = true,
  default = { r = 0.9, g = 0.2, b = 0.2, a = 1 },
  getColor = function()
    local color = MyAddonDB.profile.barColor or { r = 0.9, g = 0.2, b = 0.2, a = 1 }
    return color.r, color.g, color.b, color.a
  end,
  setColor = function(_, r, g, b, a)
    MyAddonDB.profile.barColor = { r = r, g = g, b = b, a = a or 1 }
    MyAddon.ApplyBarColor()
  end,
})
```

[//]: # (Links)
[Top]: #Top
