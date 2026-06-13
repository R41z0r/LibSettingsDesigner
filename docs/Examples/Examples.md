<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Examples](#examples)
- [Suggested Reading Order](#suggested-reading-order)
- [How to Use These Samples](#how-to-use-these-samples)

</details>

## [Examples][Top]

| Example | Purpose |
| :------ | :------ |
| [Minimal Addon](Minimal-Addon.md) | Small direct Config/UI setup. |
| [Complete Settings Center](Complete-Settings-Center.md) | End-to-end sample with dashboard, groups, controls, notes, search aliases, and slash command. |
| [Wrapper Bridge Pattern](Wrapper-Bridge-Pattern.md) | Addon wrapper helpers over the raw Config/UI APIs. |
| [Dependent Controls](Dependent-Controls.md) | Parent/child enablement and visibility. |
| [Dynamic Dropdowns](Dynamic-Dropdowns.md) | Lists built from runtime data. |
| [Nested Database Values](Nested-Database-Values.md) | Explicit getters/setters for nested saved-variable tables. |
| [Search and New Badges](Search-And-New-Badges.md) | Search aliases, renamed settings, and new-feature badges. |
| [Runtime Refresh](Runtime-Refresh.md) | Updating rendered rows after external state changes. |
| [Support Links](Support-Links.md) | Discord, GitHub, Ko-fi, website, and support buttons on an info page. |
| [Theme Colors](Theme-Colors.md) | Global UI chrome color overrides with per-key fallback to defaults. |

## [Suggested Reading Order][Top]

1. [Vendoring](../Vendoring.md)
2. [Quick Start](../Quick-Start.md)
3. [Field Glossary](../Field-Glossary.md)
4. [Elements](../Elements/Elements.md)
5. [Complete Settings Center](Complete-Settings-Center.md)
6. [Wrapper Bridge Pattern](Wrapper-Bridge-Pattern.md), when the host addon has wrappers

## [How to Use These Samples][Top]

- Copy the structure, not the placeholder names.
- Replace `MyAddon`, `MyAddonDB`, and feature names with host addon names.
- Keep `assetRoot` pointed at the vendored library folder.
- Keep ids stable and non-localized.
- Prefer direct `key` fields for simple DB values.
- Prefer explicit getters/setters for nested DB values or runtime refresh.
- Add keywords for old option names or likely user search terms.
- Do not rebuild the settings frame from dropdown or MultiDropdown click callbacks.

[//]: # (Links)
[Top]: #Top
