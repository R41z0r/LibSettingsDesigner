<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Static Options](#static-options)
- [Dynamic Options](#dynamic-options)

</details>

## [Overview][Top]

A dropdown stores one selected value.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `list` / `options` | table | Value-to-label map or ordered option list. |
| `orderList` / `order` | table | Deterministic display order. |
| `listFunc` | function | Dynamic option map provider. |
| `optionfunc` | function | Dynamic order/options provider. |
| `menuHeight` | number | Menu height for long lists. |
| `customDefaultText` | string | Text when no value is selected. |
| `dropdownStyle` | string | Optional `"themed"` / `"modern"` opt-in for the dedicated dropdown theme slots. |
| `dropdownTextOutline` | boolean | Controls the value-text outline for themed dropdowns. Defaults to `true`; set `false` to disable it. |

The app-level `dropdownStyle` option applies the opt-in to all dropdown,
MultiDropdown, SoundDropdown, and CheckboxDropdown buttons. A control-level
value overrides the app default. Omitting it preserves the established button
appearance for existing hosts.

## [Static Options][Top]

```lua
app:RegisterControl("interface.bars", {
  id = "anchor",
  key = "anchor",
  type = "dropdown",
  label = "Anchor",
  list = {
    LEFT = "Left",
    CENTER = "Center",
    RIGHT = "Right",
  },
  orderList = { "LEFT", "CENTER", "RIGHT" },
  default = "CENTER",
})
```

## [Dynamic Options][Top]

```lua
app:RegisterControl("profiles.select", {
  id = "profile",
  key = "profile",
  type = "dropdown",
  label = "Profile",
  listFunc = function()
    return MyAddon.GetProfileLabels()
  end,
  optionfunc = function()
    return MyAddon.GetProfileOrder()
  end,
  menuHeight = 260,
})
```

[//]: # (Links)
[Top]: #Top
