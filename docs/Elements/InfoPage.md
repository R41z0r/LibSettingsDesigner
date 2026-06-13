<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Content Blocks](#content-blocks)
- [Entry Types](#entry-types)
- [Example](#example)

</details>

## [Overview][Top]

Info pages render static/help content instead of settings controls. Use
`layout = "info"`.

## [Content Blocks][Top]

```lua
{
  title = "Section title",
  entries = {
    -- entries
  },
}
```

## [Entry Types][Top]

| Type | Fields | Description |
| :--- | :----- | :---------- |
| `text` | `text` | Paragraph or bullet text. |
| `command` | `commands`, `usage`, `desc`, `note` | Slash command display. |
| `button` | `text`, `width`, `onClick` | Action button. |
| `spacer` | `height` | Vertical spacing. |

## [Example][Top]

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
        { type = "text", text = "Use these commands in chat." },
        { type = "command", commands = { "/myaddon" }, desc = "Open settings." },
        { type = "spacer", height = 8 },
        {
          type = "button",
          text = "Copy URL",
          width = 180,
          onClick = function()
            MyAddon.ShowCopyURLPopup()
          end,
        },
      },
    },
  },
})
```

[//]: # (Links)
[Top]: #Top

