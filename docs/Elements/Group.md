<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)

</details>

## [Overview][Top]

A group organizes controls inside a page. Controls join a group through
`groupID` or `modernGroup`.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `id` | string | Stable group id. |
| `title` | string | Display heading. |
| `order` | number | Sort order. |

## [Example][Top]

```lua
app:RegisterGroup("interface.action-bars", {
  id = "visibility",
  title = "Visibility",
  order = 200,
})

app:RegisterControl("interface.action-bars", {
  id = "fadeOut",
  key = "fadeOut",
  groupID = "visibility",
  type = "toggle",
  label = "Fade out",
  default = false,
})
```

[//]: # (Links)
[Top]: #Top

