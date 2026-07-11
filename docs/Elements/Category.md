<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)
- [Page Tabs](#page-tabs)

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
| `tabView` | table/boolean/function | Enables horizontal page tabs for this category. |
| `pageTabs` / `tabs` / `tabbedPages` | boolean/function | Simple aliases for `tabView`. |
| `defaultPageID` / `defaultPage` / `pageID` | string | Initial page for category tab view. |
| `rememberSelectedPage` / `rememberTab` | boolean | Remember last selected tab page for this category. |
| `sidebarSection` / `navSection` / `section` | string/table/function | Optional section heading in the left sidebar. |
| `sidebarSectionTitle` / `sectionTitle` | string/function | Display label when it differs from the section id. |

## [Example][Top]

```lua
app:RegisterCategory({
  id = "interface",
  title = INTERFACE_LABEL or "Interface",
  order = 100,
  iconAtlas = "hud-microbutton-character-up",
  sidebarSection = "Core",
})
```

## [Page Tabs][Top]

Use `tabView` when a sidebar category should open directly into one of its
pages and show the category's sibling pages as horizontal tabs above the detail
content.

```lua
local app = Config:RegisterAddOn(addonName, {
  getSelectedCategoryPage = function(categoryID)
    return MyAddonDB.profile.settingsTabs
      and MyAddonDB.profile.settingsTabs[categoryID]
  end,
  setSelectedCategoryPage = function(categoryID, pageID)
    MyAddonDB.profile.settingsTabs = MyAddonDB.profile.settingsTabs or {}
    MyAddonDB.profile.settingsTabs[categoryID] = pageID
  end,
})

app:RegisterCategory({
  id = "icons",
  title = "Icons",
  tabView = {
    enabled = true,
    panel = true,
    defaultPageID = "icons.catalog",
    remember = true,
  },
  order = 100,
})

app:RegisterPage({
  id = "icons.groups",
  category = "icons",
  title = "Groups",
  order = 100,
})

app:RegisterPage({
  id = "icons.catalog",
  category = "icons",
  title = "Icon Catalog",
  tabTitle = "Catalog",
  order = 200,
})
```

When `remember = true`, the selected page is kept in the open frame state and
can be persisted through the app callbacks shown above. Without a remembered
page, the category opens `defaultPageID`; without a valid default, it opens the
first visible page by order.

Page tabs show a `New` badge when their page or one of its visible controls has
an active `newTagID`. The badge needs no tab-specific field: provide
`isNewTag(tagID)` on the app and place stable tags on the page or its controls.

Set `tabView.panel = true` when the tab strip should sit on a
semi-transparent background. A table value can provide `bg` / `bgColor` and
`border` / `borderColor`; otherwise the renderer uses the global tab theme
colors. The panel uses the normal backdrop border only; it does not add a
separate hard pixel outline around the whole tab strip.

Panel tables can also add a packaged texture behind the tab buttons:

```lua
tabView = {
  enabled = true,
  panel = {
    bg = { 0.00, 0.03, 0.04, 0.38 },
    border = { 0.00, 0.58, 0.72, 0.45 },
    texture = "Interface\\AddOns\\MyAddon\\Media\\Glows\\teal_horizontal_glow",
    textureAlpha = 0.82,
    textureBlendMode = "ADD",
    textureColor = { 0.62, 1.00, 0.92, 1 },
    textureInsets = { left = 0, right = 0, top = 1, bottom = 1 },
  },
}
```

Texture paths must point to files shipped by the host addon. Do not use local
absolute development paths in registration data.

[//]: # (Links)
[Top]: #Top
