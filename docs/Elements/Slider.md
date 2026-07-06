<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Preview](#preview)
- [Fields](#fields)
- [Example](#example)
- [Formatting](#formatting)
- [Row Actions](#row-actions)

</details>

## [Overview][Top]

A slider stores a numeric value in a bounded range.

## [Preview][Top]

![Slider layout example](../assets/images/slider-layout-example.png)

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `min` | number | Minimum value. |
| `max` | number | Maximum value. |
| `step` | number | Increment size. |
| `formatter` | function | Display formatter. |
| `suffix` | string | Suffix for display text. |
| `valueFormatter` | function | Alternate value formatter. |
| `actions` / `settingActions` | table/function | Optional small row action buttons or menus. |

## [Example][Top]

```lua
app:RegisterControl("interface.bars", {
  id = "barScale",
  key = "barScale",
  type = "slider",
  label = "Scale",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
})
```

## [Formatting][Top]

```lua
formatter = function(value)
  return string.format("%.0f%%", (tonumber(value) or 1) * 100)
end
```

## [Row Actions][Top]

Use `actions` when a slider needs a compact per-setting tool menu:

```lua
actions = {
  {
    id = "scaleTools",
    icon = "Interface\\Icons\\INV_Misc_Gear_01",
    tooltip = "Scale tools",
    menu = {
      { text = "Set 100%", onClick = function() MyAddon.SetScale(1) end },
      { text = "Set 125%", onClick = function() MyAddon.SetScale(1.25) end },
    },
  },
}
```

[//]: # (Links)
[Top]: #Top
