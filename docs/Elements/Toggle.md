<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Simple DB Toggle](#simple-db-toggle)
- [Explicit Getter and Setter](#explicit-getter-and-setter)
- [Common Mistakes](#common-mistakes)

</details>

## [Overview][Top]

A toggle stores a boolean value. Use `type = "toggle"` or `type = "checkbox"`.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `id` | string | Stable control id. |
| `key` / `var` | string | DB key for default persistence. |
| `label` / `text` | string | Row label. |
| `description` / `desc` | string | Short explanation. |
| `default` | boolean/function | Default value. |
| `getValue` / `get` | function | Explicit value reader. |
| `setValue` / `set` | function | Explicit value writer. |
| `isEnabled` | function | Disabled-state gate. |
| `parentCheck` | function | Parent enabled-state gate. |

## [Simple DB Toggle][Top]

```lua
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = ENABLE or "Enable",
  description = "Enable this feature.",
  default = true,
})
```

## [Explicit Getter and Setter][Top]

```lua
app:RegisterControl("general.core", {
  id = "privateMode",
  type = "toggle",
  label = "Private mode",
  default = false,
  getValue = function()
    return MyAddonPrivateDB.privateMode == true
  end,
  setValue = function(value)
    MyAddonPrivateDB.privateMode = value == true
    MyAddon.RefreshPrivateMode()
  end,
})
```

## [Common Mistakes][Top]

- Do not store string values like `"true"` or `"false"`.
- Do not rebuild the settings frame from the setter.
- Use explicit getters/setters for nested DB values.

[//]: # (Links)
[Top]: #Top

