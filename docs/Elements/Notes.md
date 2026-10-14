<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Preview](#preview)
- [Fields](#fields)
- [Simple Note](#simple-note)
- [Rich Note](#rich-note)
- [Spacing Rule](#spacing-rule)
- [Inline hints](#inline-hints)

</details>

## [Overview][Top]

Notes provide hover help for controls and additional page documentation.

Supported control fields:

- `note`
- `notes`
- `richNote`
- `richNotes`

## [Preview][Top]

![Control note example](../assets/images/control-note-example.png)

![Rich note image example](../assets/images/rich-note-image-example.png)

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `title` | string | Optional heading. |
| `text` | string | Body text. |
| `blocks` | table | Ordered rich blocks. |
| `order` | number | Sort order. |
| `visible` / `condition` | function | Conditional display. |
| `color` | table | Text color. |
| `font` | string | Font object/template. |

## [Simple Note][Top]

```lua
note = {
  title = "Details",
  text = "Configure layout, display, bars, fonts, colors, and behavior in Edit Mode.",
}
```

## [Rich Note][Top]

```lua
notes = {
  {
    title = "Preview",
    blocks = {
      { text = "Use preview mode before entering combat." },
      { type = "spacer", height = 8 },
      {
        image = "Interface\\AddOns\\MyAddon\\Media\\preview.tga",
        width = 256,
        height = 144,
      },
    },
  },
}
```

## [Spacing Rule][Top]

The note panel measures rendered font height and removes the trailing row gap
from the final panel height. This keeps top and bottom padding visually even.


## Inline hints

Register a noninteractive `type = "inlinehint"` control for guidance that must
stay visible without hovering. `label` contains the localized hint, and optional
`textColor` accepts RGBA array or named fields. The default is soft mint green
`{ 0.60, 0.86, 0.76, 1 }`. It spans all control columns, wraps at the available
width, and measures rendered font height on layout. It has no background,
separator, input, or hover tooltip, and never counts as customized.

```lua
app:RegisterControl("interface.action-bars", {
  id = "visibility.hint",
  groupID = "visibility",
  type = "inlinehint",
  label = "Move and customize enabled elements in Edit Mode.",
  order = 110,
})
```

Keep `description` and `notes` for hover help. Use a stable id and group/order
for inline hints; do not attach them to the previously registered control.

[//]: # (Links)
[Top]: #Top
