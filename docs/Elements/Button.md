<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)

</details>

## [Overview][Top]

A button runs an action. It normally does not track customized state.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `label` | string | Row label. |
| `buttonText` | string | Text shown on the button. |
| `onClick` / `setValue` | function | Click handler. |
| `description` | string | Action description. |

## [Example][Top]

```lua
app:RegisterControl("profiles.export", {
  id = "exportProfile",
  type = "button",
  label = "Export profile",
  buttonText = "Export",
  description = "Create an export string for the current profile.",
  onClick = function()
    MyAddon.ShowExportPopup()
  end,
})
```

[//]: # (Links)
[Top]: #Top

