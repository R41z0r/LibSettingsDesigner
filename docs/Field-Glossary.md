<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Purpose](#purpose)
- [App Fields](#app-fields)
- [Category Fields](#category-fields)
- [Page Fields](#page-fields)
- [Group Fields](#group-fields)
- [Common Control Fields](#common-control-fields)
- [Value Fields](#value-fields)
- [Visibility and Enabled Fields](#visibility-and-enabled-fields)
- [Search and Badge Fields](#search-and-badge-fields)
- [Element-Specific Field Map](#element-specific-field-map)
- [Alias Rules](#alias-rules)

</details>

## [Purpose][Top]

This page is the quick lookup for metadata fields used by
LibSettingsDesigner. Use it when creating examples, reviewing docs, or adding a
new setting to a host addon.

For full behavior and examples, use the dedicated element pages under
[Elements](Elements/Elements.md).

## [App Fields][Top]

Passed to:

```lua
Config:RegisterAddOn(addonID, opts)
```

| Field | Type | Meaning |
| :---- | :--- | :------ |
| `title` | string | Short addon name used in dashboard/sidebar areas. |
| `settingsTitle` | string | Main window title. |
| `dashboardTitle` | string | Label for the dashboard navigation entry. |
| `icon` | string | Main addon icon texture path. |
| `addonFolder` / `folder` | string | Host addon folder name, used for fallback asset paths. |
| `assetRoot` | string | Explicit path to vendored LibSettingsDesigner assets. Should usually end with `\\Assets\\`. |
| `db` | function | Returns the table used for simple DB-backed controls. |
| `locale` | table | Host addon locale table. |
| `density` | string/function | Initial density, usually `"compact"` or `"comfortable"`. |
| `getDensity(app)` / `setDensity(density, app)` | function | Read/write the user's selected density. |
| `showDensityButton` / `showDensityButton(app)` | boolean/function | Controls whether users can switch density; only `false` hides the button. |
| `getSize()` / `setSize(width, height)` | function | Read/write persisted frame size. |
| `getLocked()` / `setLocked(locked)` | function | Read/write whether the frame is locked. |
| `dashboard` | table/function | Dashboard configuration. |
| `isNewTag` | function | Returns whether a `newTagID` should show a badge. |
| `iconTextures` | table | Maps icon keys to texture paths. |
| `categoryIconTextures` | table | Maps category ids/keys to texture paths. |
| `pageDescriptionKeys` / `pageDescriptionLocaleKeys` | table | Maps page ids/keys to locale keys for descriptions. |
| `openLegacySettings` | function | Called by bridge controls that jump to Blizzard settings. |
| `blizzardSettingsRoot` | boolean | `true` registers a lightweight Blizzard Settings bridge entry. |
| `blizzardSettingsTitle` | string | Optional title for the Blizzard Settings bridge entry. |
| `openSettings(app)` | function | Called by the Blizzard Settings bridge button. |

`profile` and `version` are host-owned metadata in the current runtime. They do
not automatically render profile/status/version UI unless host addon code or a
custom dashboard function reads them.

Example:

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  settingsTitle = "My Addon Settings",
  dashboardTitle = "Dashboard",
  addonFolder = addonName,
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  density = "compact",
  getDensity = function() return MyAddonDB.profile.settingsWindow and MyAddonDB.profile.settingsWindow.density end,
  setDensity = function(value)
    MyAddonDB.profile.settingsWindow = MyAddonDB.profile.settingsWindow or {}
    MyAddonDB.profile.settingsWindow.density = value
  end,
  db = function() return MyAddonDB.profile end,
  locale = L,
})
```

## [Category Fields][Top]

Passed to:

```lua
app:RegisterCategory(data)
```

| Field | Type | Meaning |
| :---- | :--- | :------ |
| `id` | string | Required stable category id. |
| `title` | string | Display label. |
| `order` | number | Sort order. |
| `icon` | string | Texture path. |
| `iconAtlas` | string | Blizzard atlas name. |
| `iconKey` | string | Lookup key in app icon maps. |

## [Page Fields][Top]

Passed to:

```lua
app:RegisterPage(data)
```

| Field | Type | Meaning |
| :---- | :--- | :------ |
| `id` | string | Required stable page id. |
| `category` | string | Parent category id. |
| `title` | string | Display label. |
| `description` | string | Summary shown on cards/detail views. |
| `icon`, `iconAtlas`, `iconKey` | string | Page icon source. |
| `mainToggleID` | string | Control id used as main feature toggle. |
| `newTagID` | string | New badge tag for the page. |
| `onOpen` | function | Called as `onOpen(page, app, state)` when the page opens. |
| `order` | number | Sort order. |
| `layout` | string | Use `"info"` for static/help pages. |
| `content` | table | Info page content blocks. |
| `blocks` / `infoBlocks` | table | Alternate info content tables. `blocks` alone does not select info-page rendering. |
| `visible`, `isVisible`, `visibleWhen` | boolean/function | Show gates. |
| `hidden`, `hiddenWhen` | boolean/function | Hide gates. |

## [Group Fields][Top]

Passed to:

```lua
app:RegisterGroup(pageID, data)
```

| Field | Type | Meaning |
| :---- | :--- | :------ |
| `id` | string | Stable group id. |
| `title` | string | Group heading. |
| `order` | number | Sort order. |

Direct controls join a group with `groupID`. `modernGroup` is a wrapper/legacy
alias and must be mapped before or through `RegisterLegacyControl`.

## [Common Control Fields][Top]

Passed to:

```lua
app:RegisterControl(pageID, data)
```

| Field | Type | Meaning |
| :---- | :--- | :------ |
| `id` | string | Stable control id. Defaults to `key` when omitted. |
| `type` | string | Widget type, such as `toggle`, `slider`, `dropdown`. |
| `key` | string | DB key for simple `opts.db()` persistence. |
| `label` | string | User-visible row label. |
| `description` | string | Short row description. |
| `groupID` | string | Direct group assignment. |
| `order` | number | Sort order within page/group. |
| `default` | any/function | Default value used by reset/customized checks. |
| `dbDefault` | any/function | Alternate DB default provider. |
| `trackCustomized` | boolean | Set exactly `false` to disable customized-count behavior. |
| `refreshOnChange` | boolean | Re-render visible content after a value changes. |

Direct `RegisterControl` calls should use canonical fields. Legacy aliases such
as `var`, `text`, `name`, `desc`, `get`, and `set` are mapped by
`RegisterLegacyControl`, not by plain direct controls.

## [Value Fields][Top]

| Field | Use when |
| :---- | :------- |
| `key` | The value is directly under `opts.db()`. |
| `getValue` | You need custom read logic. |
| `setValue` | You need custom write logic or runtime refresh. |
| `getSelection` | MultiDropdown reads an entire boolean selection map. |
| `setSelection` | MultiDropdown writes an entire boolean selection map. |
| `isSelectedFunc` | MultiDropdown reads one option at a time. |
| `setSelectedFunc` | MultiDropdown writes one option at a time. |
| `setting` | Existing settings object with `GetValue`/`SetValue`/default methods. |

Use explicit getters/setters for nested DB tables:

```lua
getValue = function()
  return MyAddonDB.profile.window and MyAddonDB.profile.window.scale or 1
end,
setValue = function(value)
  MyAddonDB.profile.window = MyAddonDB.profile.window or {}
  MyAddonDB.profile.window.scale = tonumber(value) or 1
  MyAddon.RefreshWindow()
end
```

## [Visibility and Enabled Fields][Top]

Use visibility when the row/page should disappear:

```lua
visibleWhen = function(control, app)
  return MyAddon.HasAdvancedMode()
end
```

Use enabled state when the row should remain visible but disabled:

```lua
parentCheck = function()
  return MyAddonDB.profile.enabled == true
end
```

| Field | Result |
| :---- | :----- |
| `visible`, `isVisible`, `visibleWhen` | Show only when true. |
| `hidden`, `hiddenWhen` | Hide when true. |
| `isEnabled` | Disable row when false. |
| `parentCheck` | Disable child row when parent check is false. |

## [Search and Badge Fields][Top]

| Field | Meaning |
| :---- | :------ |
| `keywords` | Extra search aliases. String or table. |
| `searchtags` | Extra search aliases. String or table. |
| `newTagID` | Badge tag checked by `opts.isNewTag(tagID)`. |

Example:

```lua
app:RegisterControl("interface.names", {
  id = "showNicknames",
  key = "showNicknames",
  type = "toggle",
  label = "Show nicknames",
  description = "Use nicknames in group frames.",
  keywords = { "alias", "display name", "social" },
  newTagID = "Nicknames",
  default = false,
})
```

## [Element-Specific Field Map][Top]

| Element | Key fields | Reference |
| :------ | :--------- | :-------- |
| Toggle | `default`, `getValue`, `setValue`, `parentCheck` | [Toggle](Elements/Toggle.md) |
| Slider | `min`, `max`, `step`, `formatter`, `suffix` | [Slider](Elements/Slider.md) |
| Dropdown | `list`, `options`, `orderList`, `listFunc`, `optionfunc`, `menuHeight` | [Dropdown](Elements/Dropdown.md) |
| MultiDropdown | `getSelection`, `setSelection`, `isSelectedFunc`, `setSelectedFunc` | [MultiDropdown](Elements/MultiDropdown.md) |
| Input | `numeric`, `min`, `max`, `maxChars`, `multiline`, `readOnly` | [Input](Elements/Input.md) |
| Button | `buttonText`, `onClick`, `setValue` | [Button](Elements/Button.md) |
| ColorPicker | `getColor`, `setColor`, `hasOpacity` | [ColorPicker](Elements/ColorPicker.md) |
| ColorOverrides | `entries`, `getColor`, `setColor`, `hasOpacity`, `colorizeLabel` | [ColorOverrides](Elements/ColorOverrides.md) |
| SoundDropdown | `soundResolver`, `previewSoundFunc`, `playbackChannel` | [SoundDropdown](Elements/SoundDropdown.md) |
| CheckboxDropdown | `dropdownKey`, `dropdownList`, `dropdownOrder`, `dropdownDefault` | [CheckboxDropdown](Elements/CheckboxDropdown.md) |
| ReorderList | `getEntries`, `moveEntry`, `removeEntry`, `setEntryFormat` | [ReorderList](Elements/ReorderList.md) |
| Notes | `note`, `notes`, `richNote`, `richNotes`, `blocks` | [Notes](Elements/Notes.md) |
| Dashboard | `hero`, `cards`, `status`, `features`, `newEntries` | [Dashboard](Elements/Dashboard.md) |
| InfoPage | `layout = "info"`, `content`, `entries` | [InfoPage](Elements/InfoPage.md) |
| Expandable | `type = "expandable"`, `id`, `title`, `rightText`, `entries` | [Expandable](Elements/Expandable.md) |

## [Alias Rules][Top]

Aliases exist to support wrapper bridges and older settings helper names.
Prefer the canonical field in new direct LibSettingsDesigner examples. Legacy
aliases such as `var`, `text`, `desc`, `get`, `set`, and `modernGroup` are safe
when a wrapper or `RegisterLegacyControl` maps them first; do not assume every
alias is consumed by plain direct registration.

| Prefer | Accepted aliases |
| :----- | :--------------- |
| `key` | `var` |
| `label` | `text`, `name` |
| `description` | `desc` |
| `getValue` | `get` |
| `setValue` | `set` |
| `groupID` | `modernGroup` |
| `list` | `options` |
| `orderList` | `order` |

When documenting wrapper code, use the wrapper's native names at the wrapper
boundary, then show how they map to canonical LibSettingsDesigner fields inside
the wrapper.

[//]: # (Links)
[Top]: #Top
