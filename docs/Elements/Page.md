<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Settings Page](#settings-page)
- [Info Page](#info-page)

</details>

## [Overview][Top]

A page contains controls or info content. Pages appear as cards and detail views
inside a category.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `id` | string | Stable page id. Required. |
| `category` | string | Parent category id. |
| `title` | string | Display title. |
| `description` | string | Page summary/about text. |
| `icon`, `iconAtlas`, `iconKey` | string | Icon source. |
| `mainToggleID` | string | Control id used as main feature toggle. |
| `tabTitle` | string | Optional shorter label when rendered in a category tab strip. |
| `tabHidden` / `hideTab` | boolean | Hide this page from category tab strips. |
| `newTagID` | string | New badge tag. |
| `layout` | string | Use `"info"` for static content pages. |
| `content` | table | Info page content. |
| `blocks` / `infoBlocks` | table | Alternate info content tables. `blocks` alone does not select info-page rendering. |
| `visible`, `isVisible`, `visibleWhen` | boolean/function | Show gates. |
| `hidden`, `hiddenWhen` | boolean/function | Hide gates. |
| `order` | number | Sort order. |

## [Settings Page][Top]

```lua
app:RegisterPage({
  id = "interface.action-bars",
  category = "interface",
  title = "Action Bars",
  description = "Configure action bar behavior.",
  iconKey = "actionbar",
  mainToggleID = "actionBarsEnabled",
  order = 100,
})
```

## [Info Page][Top]

```lua
app:RegisterPage({
  id = "help.quick-reference",
  category = "help",
  title = "Quick Reference",
  layout = "info",
  content = {
    {
      title = "Slash Commands",
      entries = {
        { type = "command", commands = { "/myaddon" }, desc = "Open settings." },
      },
    },
  },
})
```

[//]: # (Links)
[Top]: #Top
