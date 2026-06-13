<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)

</details>

## [Overview][Top]

A category is a top-level sidebar bucket for related pages.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `id` | string | Stable category id. Required. |
| `title` | string | Display label. |
| `order` | number | Sort order. |
| `icon` | string | Texture path. |
| `iconAtlas` | string | Blizzard atlas name. |
| `iconKey` | string | Lookup key in app icon maps. |

## [Example][Top]

```lua
app:RegisterCategory({
  id = "interface",
  title = INTERFACE_LABEL or "Interface",
  order = 100,
  iconAtlas = "hud-microbutton-character-up",
})
```

[//]: # (Links)
[Top]: #Top

