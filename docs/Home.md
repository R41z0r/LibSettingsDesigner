<a name="Top"></a>

Welcome to the wiki for **LibSettingsDesigner**, a vendored settings-center
library for World of Warcraft addons.

LibSettingsDesigner is not a shared LibStub package. It is loaded into the host
addon's namespace as:

```lua
addon.LibSettingsDesigner.Config
addon.LibSettingsDesigner.UI
```

Use this wiki when integrating the library, adding settings pages, building
wrapper bridges, documenting elements, or validating changes.

## [Start Here][Top]

| Page | Use it for |
| :--- | :--------- |
| [Architecture](Architecture.md) | Mental model, data flow, runtime boundaries. |
| [Vendoring](Vendoring.md) | Folder layout, TOC/XML loading, assets, LibStub rules. |
| [Quick Start](Quick-Start.md) | Smallest useful copy/paste setup. |
| [Field Glossary](Field-Glossary.md) | Field names, aliases, value/default/visibility rules. |
| [Troubleshooting](Troubleshooting.md) | Common failures and fixes. |
| [Validation](Validation.md) | Checks and handoff template. |

## [Reference][Top]

| Page | Use it for |
| :--- | :--------- |
| [Config API](API/Config-API.md) | App/category/page/group/control registration and value model. |
| [UI API](API/UI-API.md) | Opening, toggling, frame state, refresh rules. |
| [Elements](Elements/Elements.md) | All rendered element types. |
| [Examples](Examples/Examples.md) | Copyable patterns and samples. |

## [Element Pages][Top]

- [Category](Elements/Category.md)
- [Page](Elements/Page.md)
- [Group](Elements/Group.md)
- [Toggle](Elements/Toggle.md)
- [Slider](Elements/Slider.md)
- [Dropdown](Elements/Dropdown.md)
- [MultiDropdown](Elements/MultiDropdown.md)
- [Input](Elements/Input.md)
- [Button](Elements/Button.md)
- [ColorPicker](Elements/ColorPicker.md)
- [ColorOverrides](Elements/ColorOverrides.md)
- [SoundDropdown](Elements/SoundDropdown.md)
- [CheckboxDropdown](Elements/CheckboxDropdown.md)
- [ReorderList](Elements/ReorderList.md)
- [Notes](Elements/Notes.md)
- [Dashboard](Elements/Dashboard.md)
- [Expandable](Elements/Expandable.md)
- [InfoPage](Elements/InfoPage.md)

## [Examples][Top]

- [Minimal Addon](Examples/Minimal-Addon.md)
- [Complete Settings Center](Examples/Complete-Settings-Center.md)
- [Wrapper Bridge Pattern](Examples/Wrapper-Bridge-Pattern.md)
- [Dependent Controls](Examples/Dependent-Controls.md)
- [Dynamic Dropdowns](Examples/Dynamic-Dropdowns.md)
- [Nested Database Values](Examples/Nested-Database-Values.md)
- [Search and New Badges](Examples/Search-And-New-Badges.md)
- [Runtime Refresh](Examples/Runtime-Refresh.md)
- [Support Links](Examples/Support-Links.md)
- [Theme Colors](Examples/Theme-Colors.md)

## [Principles][Top]

- Every addon owns its vendored copy.
- Feature strings belong to the host addon locale files.
- Stable ids are required for pages, groups, and controls.
- Use explicit getters/setters for anything that is not a simple profile DB key.
- Keep callbacks focused on persistence and runtime refresh.
- Use notes/info pages for long explanations instead of oversized row text.
- Do not rebuild the settings frame from dropdown or MultiDropdown selection callbacks.
- Keep documentation and examples in sync with code when source files are available.

[//]: # (Links)
[Top]: #Top
