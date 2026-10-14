<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Value Shape](#value-shape)
- [Example](#example)

</details>

## [Overview][Top]

Inline hints provide always-visible, noninteractive guidance inside a settings
group. They span the control columns, wrap to the available width, and use soft
mint text by default. They have no background, separator, input, or hover tooltip.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `id` | string | Stable control identity. |
| `type` | string | Use `"inlinehint"`. |
| `label` | string | Hint text, localized by the host addon. |
| `groupID` | string | Owning group. |
| `order` | number | Position among controls. |
| `textColor` | table | Optional RGBA array or named `r`, `g`, `b`, `a` fields; default `{ 0.60, 0.86, 0.76, 1 }`. |
| `hiddenWhen` / `visibleWhen` | function | Standard control visibility gates. |

Height is measured from wrapped text; fixed row heights do not override it.
Use descriptions and notes on interactive controls for hover help instead.

## [Value Shape][Top]

No saved value. Omit `key`, `default`, getters, and setters. Registration forces
`trackCustomized = false`, so hints never count as customized settings.

## [Example][Top]

After registering the page, register a group and its hint:

```lua
app:RegisterGroup("interface.action-bars", {
  id = "visibility", title = "Visibility", columns = 2, order = 100,
})
app:RegisterControl("interface.action-bars", {
  id = "visibility.hint",
  groupID = "visibility",
  type = "inlinehint",
  label = "Move and customize enabled elements in Edit Mode.",
  order = 110,
})
```

Replace display strings with the host's locale values. Wrappers should register
hints as independent controls with stable ids, rather than attaching a note to
the previous control.

[//]: # (Links)
[Top]: #Top
