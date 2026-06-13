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
| `hasOpacity` | boolean | Show alpha channel. |
| `colorizeLabel` | boolean | Tint label with current color. |
| `callback` | function | Called after color changes. |
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
  callback = function(color)
    MyAddon.ApplyBarColor(color)
  end,
})
```

[//]: # (Links)
[Top]: #Top

