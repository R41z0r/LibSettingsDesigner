<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Structure Elements](#structure-elements)
- [Control Elements](#control-elements)
- [Content Elements](#content-elements)
- [Choosing the Right Element](#choosing-the-right-element)
- [Common Control Fields](#common-control-fields)

</details>

## [Overview][Top]

Elements are the building blocks rendered by LibSettingsDesigner. Categories,
pages, and groups define structure. Controls edit values or run actions. Content
elements provide dashboard, notes, and help/info pages.

For all shared fields and aliases, see [Field Glossary](../Field-Glossary.md).

## [Structure Elements][Top]

| Element | Purpose |
| :------ | :------ |
| [Category](Category.md) | Top-level sidebar category. |
| [Page](Page.md) | A settings page under a category. |
| [Group](Group.md) | A section of controls inside a page. |

## [Control Elements][Top]

| Element | Purpose |
| :------ | :------ |
| [Toggle](Toggle.md) | Boolean on/off setting. |
| [Slider](Slider.md) | Numeric range setting. |
| [Dropdown](Dropdown.md) | Single choice from a list. |
| [MultiDropdown](MultiDropdown.md) | Multiple choices stored as a boolean map. |
| [Input](Input.md) | Text, numeric, or multiline input. |
| [Button](Button.md) | Action row. |
| [ColorPicker](ColorPicker.md) | Single color value. |
| [ColorPalette](ColorPalette.md) | Multiple keyed colors in one row. |
| [ColorOverrides](ColorOverrides.md) | Legacy alias for ColorPalette. |
| [SoundDropdown](SoundDropdown.md) | Single sound choice with preview support. |
| [CheckboxDropdown](CheckboxDropdown.md) | Boolean setting plus related dropdown. |
| [ReorderList](ReorderList.md) | Ordered editable list. |

## [Content Elements][Top]

| Element | Purpose |
| :------ | :------ |
| [Notes](Notes.md) | Hover notes, rich notes, text, images, and spacers. |
| [Dashboard](Dashboard.md) | Landing dashboard configuration. |
| [InfoPage](InfoPage.md) | Static/help pages with text, commands, buttons, and spacers. |
| [Expandable](Expandable.md) | Collapsible info-page sections for changelogs, FAQs, and release notes. |

## [Choosing the Right Element][Top]

| Need | Use |
| :--- | :-- |
| Enable/disable a feature | [Toggle](Toggle.md) |
| Numeric value with min/max | [Slider](Slider.md) |
| Pick exactly one option | [Dropdown](Dropdown.md) |
| Pick multiple options | [MultiDropdown](MultiDropdown.md) |
| Free text or number entry | [Input](Input.md) |
| Run an action instead of storing a setting | [Button](Button.md) |
| Store one color | [ColorPicker](ColorPicker.md) |
| Store several keyed colors | [ColorPalette](ColorPalette.md) |
| Pick and preview a sound | [SoundDropdown](SoundDropdown.md) |
| Toggle plus related mode/threshold | [CheckboxDropdown](CheckboxDropdown.md) |
| Let users reorder entries | [ReorderList](ReorderList.md) |
| Add long explanatory hover help | [Notes](Notes.md) |
| Create a non-settings help page | [InfoPage](InfoPage.md) |
| Add collapsible changelog text | [Expandable](Expandable.md) |
| Create a landing overview | [Dashboard](Dashboard.md) |

## [Common Control Fields][Top]

Most controls share these fields:

```lua
{
  id = "stableControlID",
  key = "directDBKey",
  type = "toggle",
  label = "Visible label",
  description = "Short row description.",
  default = true,
  groupID = "behavior",
  order = 100,
  keywords = { "alias", "old setting name" },
}
```

Use explicit `getValue`/`setValue` instead of `key` for nested DB values or
runtime refresh that cannot be handled by a simple direct assignment.

[//]: # (Links)
[Top]: #Top
