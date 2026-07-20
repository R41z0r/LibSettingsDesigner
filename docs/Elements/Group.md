<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)

</details>

## [Overview][Top]

A group organizes controls inside a page. Direct controls join a group through
`groupID`. `modernGroup` is a wrapper/legacy alias and must be mapped before or
through `RegisterLegacyControl`.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `id` | string | Stable group id. |
| `title` | string | Display heading. |
| `order` | number | Sort order. |
| `columns` / `controlColumns` | number/function | Optional number of control columns inside the group. |
| `column` / `layoutColumn` | number/string | Optional page column when the page uses `groupColumns`. |
| `columnGap` / `controlColumnGap` | number/function | Optional gap between control columns. |

## [Example][Top]

```lua
app:RegisterGroup("interface.action-bars", {
  id = "visibility",
  title = "Visibility",
  columns = 2,
  order = 200,
})

app:RegisterControl("interface.action-bars", {
  id = "fadeOut",
  key = "fadeOut",
  groupID = "visibility",
  column = 1,
  type = "toggle",
  label = "Fade out",
  default = false,
})
```

When `columns = 2`, controls without an explicit `column` flow into the shorter
column. Use `column = 1` / `column = 2` when a mixed panel should keep toggles
and sliders in predictable lanes.

When a page renders group tabs or a matrix fixed header, a group tab shows a
`New` badge if one of its controls has an active `newTagID`. Groups do not need
their own tag; keep badge state on the page controls through `opts.isNewTag`.

Matrix fixed headers also show a localized **Defaults** button for the active
group when at least one visible control is customized. After confirmation, the
button resets only visible controls in that group and leaves other groups
unchanged. It follows the app-level `topbar.showDefaults` setting, so hosts that
hide reset actions do not gain a separate group reset button.

[//]: # (Links)
[Top]: #Top
