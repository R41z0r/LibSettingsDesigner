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

## [Example][Top]

```lua
app:RegisterCategory({
  id = "interface",
  title = INTERFACE_LABEL or "Interface",
  order = 100,
  iconAtlas = "hud-microbutton-character-up",
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

[//]: # (Links)
[Top]: #Top
