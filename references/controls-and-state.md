# Controls and state

Read only the sections relevant to the requested change. Paths in code examples
are relative to the library or host checkout as indicated. `docs/` paths refer
to the skill root documentation. This reference does not authorize external
actions or reading repository instructions outside the active project.

## Direct API vs Legacy Bridge Aliases

Direct `RegisterCategory`, `RegisterPage`, `RegisterGroup`, and
`RegisterControl` registrations should use canonical runtime fields. Do not
assume legacy aliases work in direct registration unless the runtime explicitly
consumes them.

Canonical direct fields:

| Object | Canonical fields |
| :----- | :--------------- |
| Category | `id`, `title`, `description`, `order`, `icon`, `iconAtlas`, `iconKey`, `tabView`, `pageTabs`, `tabs`, `tabbedPages`, `defaultPageID`, `rememberSelectedPage`, `sidebarSection`, `sidebarSectionTitle`, `sectionTitle` |
| Page | `id`, `category`, `title`, `description`, `descriptionKey`, `order`, `icon`, `iconAtlas`, `iconKey`, `mainToggleID`, `tabTitle`, `tabHidden`, `pageKey`, `newTagID`, `sidePanel`, `rightPanel`, `detailPanel`, `showSidePanel`, `groupColumns`, `columnGap`, `groupSort`, `sortGroups`, `onOpen`, `layout`, `type`, `content`, `blocks`, `infoBlocks`, `searchEntries`, `getHeight`, `render`, `refresh`, `release`, `getSettingCount`, `getCustomizedCount` |
| Group | `id`, `title`, `order`, `columns`, `controlColumns`, `column`, `layoutColumn`, `columnGap`, `controlColumnGap` |
| Control | `id`, `key`, `type`, `label`, `description`, `default`, `dbDefault`, `getValue`, `setValue`, `getSelection`, `setSelection`, `setting`, `parentCheck`, `isEnabled`, `column`, `actions`, visibility fields, search fields |

Legacy aliases are mapped by `RegisterLegacyCategory`,
`RegisterLegacySection`, and `RegisterLegacyControl`, not by plain direct
controls:

| Legacy alias | Canonical runtime field |
| :----------- | :---------------------- |
| `var` | `key` |
| `text` / `name` | `label` |
| `desc` | `description` |
| `get` | `getValue` |
| `set` | `setValue` |
| `modernGroup` | `groupID` |
| `sType` | `type` or UI type alias |

Important: in direct `RegisterControl`, `var` may become the generated control
id, but it does not become `key`. DB-backed controls must set `key`.
In direct `RegisterControl`, use `groupID`. `modernGroup` is only normalized by
`RegisterLegacyControl` / wrapper bridge code.
`sType` is accepted by legacy/UI type resolution, but new direct registrations
should always set `type`. Some Config-side logic checks `control.type` directly.

Migration rule: when creating new settings code or substantially touching an
existing direct LibSettingsDesigner registration, migrate it to canonical direct
fields instead of preserving legacy aliases. Keep legacy aliases only at wrapper
boundaries or inside `RegisterLegacy*` bridge code. Do not mass-migrate
unrelated host-addon settings in the same change; migrate incrementally where
the touched code can be validated.

## Control Field Reference

Common fields:

| Field | Use |
| :---- | :-- |
| `id` | Stable control identity. |
| `key` | Direct DB key under `opts.db()`. |
| `type` | Canonical widget type. |
| `label` | Display label. |
| `description` | Short description. |
| `default` / `dbDefault` | Reset/customized default. |
| `getValue` | Explicit reader. |
| `setValue` | Explicit writer. |
| `setting` | Existing settings object with `GetValue`/`SetValue`/default methods. |
| `groupID` | Direct group assignment. |
| `column` / `layoutColumn` / `columnIndex` | Control column inside a multi-column group. |
| `actions` / `settingActions` / `controlActions` | Optional small row action buttons or menus. |
| `isEnabled` / `parentCheck` | Disabled-state gates. |
| `visible` / `isVisible` / `visibleWhen` | Visibility show gates. |
| `hidden` / `hiddenWhen` | Visibility hide gates. |
| `keywords` / `searchtags` | Search aliases. |
| `newTagID` | New badge tag. |
| `trackCustomized` | Customized-count override. |
| `refreshOnChange` | Re-render content after change. |
| `requiresReload` / `reloadRequired` / `requiresUIReload` | Mark the app reload-pending after a successful value write. |
| `reloadReason` | Optional reason text for the reload button tooltip. |

Use `key` for direct profile keys:

```lua
-- Reads/writes MyAddonDB.profile.enabled
key = "enabled"
```

Use explicit getters/setters for nested DB:

```lua
getValue = function()
  return MyAddonDB.profile.bars and MyAddonDB.profile.bars.scale or 1
end,
setValue = function(value)
  MyAddonDB.profile.bars = MyAddonDB.profile.bars or {}
  MyAddonDB.profile.bars.scale = tonumber(value) or 1
  MyAddon.RefreshBars()
end
```

Avoid `key = "nested.path"` in direct LibSettingsDesigner registrations. The
runtime treats `key` as a literal table key. Use explicit getters/setters for
nested values. Do not rely on `subvar` for direct value reads/writes; it only
helps the customized-state check for legacy-shaped metadata.

Element-specific fields the agent should know. List only fields the current
runtime actively consumes as UI behavior:

| Element | Important runtime-consumed fields |
| :------ | :-------------------------------- |
| Toggle/Checkbox | `default`, `key`, `getValue`, `setValue`, `parentCheck`, `isEnabled`, `refreshOnChange`, `requiresReload` |
| Slider | `min`, `max`, `step`, `formatter`, `valueFormatter`, `suffix`, `actions` |
| Dropdown/ScrollDropdown | `values`, `options`, `list`, `orderList`, `order`, `listFunc`, `optionfunc`, `menuHeight`, `dropdownStyle`, `dropdownTextOutline` |
| MultiDropdown | `getSelection`, `setSelection`, `isSelectedFunc`, `setSelectedFunc`, `selectionSource`, `summary`, `callback`, `menuHeight`, `selectAllLabel` |
| Input | `numeric`, `min`, `max`, `step`, `clampToRange`, `maxChars`, `readOnly`, `inputWidth`, `multiline`, `inputStyle` |
| Button | `buttonText`, `onClick`, `setValue`, `trackCustomized = false` |
| ColorPicker | `getColor`, `setColor`, `hasOpacity` |
| ColorPalette | `entries`, `getColor`, `setColor`, `hasOpacity`, `colorizeLabel`, `hasOverride`, `clearColor`, `getInheritedColor`, `getDefaultColor` |
| SoundDropdown | `soundResolver`, `previewSoundFunc`, `previewTooltip`, `playbackChannel`, `getPlaybackChannel`, `menuHeight` |
| CheckboxDropdown | `dropdownKey`, `dropdownDefault`, `dropdownValues`, `dropdownOptions`, `dropdownList`, `dropdownOrder`, `dropdownGet`, `dropdownSet` |
| ReorderList | `getEntries`, `addEntry`, `removeEntry`, `moveEntry`, `setEntryFormat`, `formatOptions`, `formatOrder`, `formatEntryLabel`, `showEntryID`, `showAddButton`, `showRemoveButton`, `entryToggle`, `rowActions`, `emptyText`, `addButtonText`, `addPopupText`, `addPopupTitle`, `numeric`, `maxChars`, `rowHeight` |
| InlineHint | `type = "inlinehint"`, `label`, `textColor`, visibility gates; no saved value |
| Section heading | `type = "sectionheader"`, `justifyH`, `headerStyle`, `indent`, `textColor` |
| Custom | `type = "custom"`, `hideHeader`, `rowHeight`, `getHeight`, `render`, `refresh`, `release` |
| Keybind | Legacy/fallback bridge control; prefer host wrapper or `openLegacySettings` patterns. |

Use `type = "colorpalette"` for multiple keyed colors in new code.
`type = "coloroverrides"` and `type = "coloroverride"` are legacy aliases and
must remain accepted for old host addons.

Do not document these as active UI behavior unless runtime support is added:

- MultiDropdown `hideSummary`
- Input `multilineHeight`
- ColorPicker `callback`
- ColorPicker `colorizeLabel`

## Inline Section Header Alignment

Use a `sectionheader` control with `justifyH = "CENTER"` for a centered
heading spanning a group's control columns. The default is `"LEFT"`;
`"RIGHT"` is also supported. Legacy wrappers must forward `justifyH`.
Icons stay left-aligned and reserve label space; omit them for a title
centered across the whole row. See `docs/Elements/Group.md`.

## Visible Inline Hints

Use `type = "inlinehint"` with localized `label` and optional `textColor` for
always-visible guidance. Hints span group columns and measure wrapped text,
use soft mint by default, and do not display hover help. Host wrappers should
register them as controls with stable ids, not as notes on a previous control.
See `docs/Elements/InlineHint.md`.

## Always-Visible Subgroups

Use `headerStyle = "subtle"` for muted section headings without separators,
and `indent = 16` on grouped controls to visually nest a subgroup. Indentation
is clamped to 0–48 UI units. Keep heading/child visibility consistent; there is
no automatic collapse or dependency state. Wrappers must forward these fields.

## Custom Control Headers

Custom controls can set `hideHeader = true` to suppress their built-in label
and description. Content starts 12 UI units below the row top; account for that
in `rowHeight` / `getHeight`. Retain the label for search. See
`docs/Elements/Custom.md`.

## Value Resolution Contract

Default resolution order:

1. `control.default`
2. `control.dbDefault`
3. `control.setting:GetDefaultValue()` or `control.setting:GetDefault()`

Value read order:

1. `control.setting:GetValue()`
2. `control.getSelection(control)` or `control.getSelection()`
3. `control.getValue()`
4. `opts.db()[control.key]`
5. `control.default`

Value write order:

1. `control.setting:SetValue(value)`
2. `control.setSelection(value, control)` or `control.setSelection(value)`
3. `control.setValue(value)` or `control.setValue(nil, value)`
4. `opts.db()[control.key] = value`

If in doubt, use explicit getters/setters.

## Default, Changed, and Enabled Rules

When creating or changing a value control, always define the complete state
contract. The agent should be able to answer these questions from the
registration table alone:

1. Where is the value stored?
2. What is the default value?
3. Should the control count as changed when it differs from default?
4. Can the user currently edit it?
5. Should the row stay visible or disappear when unavailable?

Use this baseline for normal persisted settings:

```lua
app:RegisterControl("general.core", {
  id = "showFrame",
  key = "showFrame",
  type = "toggle",
  label = "Show frame",
  default = true,
})
```

`key` plus `default` is enough only when the value is stored directly in
`opts.db()[key]`.

For nested, derived, migrated, or private values, provide `getValue`,
`setValue`, and a default with the same value shape that `getValue` returns:

```lua
app:RegisterControl("layout.frame", {
  id = "frameScale",
  type = "slider",
  label = "Frame scale",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  getValue = function()
    return MyAddonDB.profile.layout and MyAddonDB.profile.layout.scale or 1
  end,
  setValue = function(value)
    MyAddonDB.profile.layout = MyAddonDB.profile.layout or {}
    MyAddonDB.profile.layout.scale = tonumber(value) or 1
  end,
})
```

Changed/customized state is automatic when:

- the control has a resolvable default
- the control is enabled
- the current stored/effective value differs from the default
- `trackCustomized` is not `false`
- the control is not an action-only type such as `button` or `keybind`

Current customized-state details:

- `trackCustomized == false` disables customized tracking.
- `trackCustomized` is not evaluated as a callback in the current runtime.
- A resolvable default is required.
- Disabled controls are never customized.
- If `control.key` is set, customized requires a stored `db[key]` value. An
  absent DB key counts as default/unmodified.
- Without `control.key`, the effective current value is compared against the
  default.

There is no public `app:ResetControl` or `app:ResetPage` runtime API. The UI
top-bar Defaults button resets the current page internally. It iterates visible
page controls, resolves each default, and calls
`app:SetControlValue(control, default)`. Disabled controls are not skipped if
they are visible.

Matrix fixed headers may show a Defaults button for the active group when that
group has customized visible controls. It uses the same internal value/default
contract, resets visible controls in that group only, and follows the app-level
`topbar.showDefaults` setting. This is UI behavior, not a new public reset API.

For composite controls such as color pickers, provide `key` or `setValue` if
reset and customized state should work through `SetControlValue`. `getColor` and
`setColor` alone only power the picker UI.

Use `trackCustomized = false` for controls that are runtime actions, diagnostics,
preview-only values, or rows where "changed from default" would be misleading:

```lua
app:RegisterControl("tools.actions", {
  id = "rebuildCache",
  type = "button",
  label = "Rebuild cache",
  onClick = function()
    MyAddon.RebuildCache()
  end,
  trackCustomized = false,
})
```

Use enabled gates when a row should remain visible but not editable:

```lua
parentCheck = function()
  return MyAddonDB.profile.enabled == true
end
```

Use visibility gates only when the row/page should disappear:

```lua
visibleWhen = function()
  return MyAddonDB.profile.advanced == true
end
```

Do not use `isEnabled` / `parentCheck` to describe defaults. They only control
interactivity. The default still belongs in `default`, `dbDefault`, or the
provided `setting` object.

## Element Routing

Read the specific element page before changing examples or behavior:

| Task | Read |
| :--- | :--- |
| Categories/sidebar | `docs/Elements/Category.md` |
| Pages/cards/detail views | `docs/Elements/Page.md` |
| Groups/headings | `docs/Elements/Group.md` |
| Boolean controls | `docs/Elements/Toggle.md` |
| Numeric ranges | `docs/Elements/Slider.md` |
| Single choice lists | `docs/Elements/Dropdown.md` |
| Multi-select lists | `docs/Elements/MultiDropdown.md` |
| Text/numeric/multiline entry | `docs/Elements/Input.md` |
| Action rows | `docs/Elements/Button.md` |
| Single colors | `docs/Elements/ColorPicker.md` |
| Multiple keyed colors | `docs/Elements/ColorPalette.md` |
| Sound selection/preview | `docs/Elements/SoundDropdown.md` |
| Checkbox plus dropdown rows | `docs/Elements/CheckboxDropdown.md` |
| Ordered editable lists | `docs/Elements/ReorderList.md` |
| Host-rendered editors | `docs/Elements/Custom.md`, `docs/Examples/Custom-Hosted-Editors.md` |
| Hover help/rich notes | `docs/Elements/Notes.md` |
| Dashboard content | `docs/Elements/Dashboard.md` |
| Static help pages | `docs/Elements/InfoPage.md` |
| Collapsible info text/changelogs | `docs/Elements/Expandable.md` |

## Element Patterns

Toggle:

```lua
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "Enabled",
  default = true,
})
```

Slider:

```lua
app:RegisterControl("layout.frame", {
  id = "scale",
  key = "scale",
  type = "slider",
  label = "Scale",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  formatter = function(value)
    return string.format("%.0f%%", (tonumber(value) or 1) * 100)
  end,
})
```

Dropdown:

```lua
app:RegisterControl("layout.frame", {
  id = "anchor",
  key = "anchor",
  type = "dropdown",
  label = "Anchor",
  list = { LEFT = "Left", CENTER = "Center", RIGHT = "Right" },
  orderList = { "LEFT", "CENTER", "RIGHT" },
  default = "CENTER",
})
```

MultiDropdown:

```lua
app:RegisterControl("group.roles", {
  id = "roles",
  type = "multidropdown",
  label = "Roles",
  options = { tank = "Tank", healer = "Healer", damage = "Damage" },
  orderList = { "tank", "healer", "damage" },
  selectAllLabel = "Select all",
  getSelection = function()
    return MyAddonDB.profile.roles or {}
  end,
  setSelectedFunc = function(value, selected)
    MyAddonDB.profile.roles = MyAddonDB.profile.roles or {}
    MyAddonDB.profile.roles[value] = selected and true or nil
    MyAddon.RefreshRoles()
  end,
  default = {},
})
```

Info page:

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

Expandable changelog entry:

```lua
{
  type = "expandable",
  id = "version-1.1.0",
  title = "Version 1.1.0",
  rightText = "2026-06-13",
  defaultExpanded = true,
  entries = {
    { type = "text", text = "|cffffd100Added|r" },
    { type = "text", text = "- Collapsible changelog sections." },
  },
}
```

ReorderList order plus visibility:

```lua
app:RegisterControl("broker.columns", {
  id = "columns",
  type = "reorderlist",
  label = "Columns",
  showAddButton = false,
  showRemoveButton = false,
  showEntryID = false,
  getEntries = function() return MyAddonDB.profile.columns end,
  moveEntry = function(fromIndex, toIndex)
    MyAddon.MoveColumn(fromIndex, toIndex)
  end,
  entryToggle = {
    getValue = function(entryID, entry)
      return entry.visible == true
    end,
    setValue = function(entryID, entry, visible)
      entry.visible = visible == true
    end,
  },
  rowActions = {
    {
      id = "rename",
      label = "Rename",
      visibleWhen = function(entry) return entry.custom == true end,
      onClick = function(entryID)
        MyAddon.OpenRenamePopup(entryID)
      end,
    },
  },
})
```

Dynamic ColorPalette with reset/inherit:

```lua
app:RegisterControl("groups.colors", {
  id = "groupColors",
  type = "colorpalette",
  label = "Group colors",
  entries = function()
    return MyAddon.BuildGroupColorEntries()
  end,
  getColor = function(key)
    local color = MyAddonDB.profile.groupColorOverrides[key]
    if color then return color.r, color.g, color.b, color.a end
  end,
  setColor = function(key, r, g, b, a)
    MyAddonDB.profile.groupColorOverrides[key] = { r = r, g = g, b = b, a = a or 1 }
  end,
  hasOverride = function(key)
    return MyAddonDB.profile.groupColorOverrides[key] ~= nil
  end,
  clearColor = function(key)
    MyAddonDB.profile.groupColorOverrides[key] = nil
  end,
  getInheritedColor = function(key)
    return MyAddon.GetBaseGroupColor(key)
  end,
})
```

Custom hosted editor page:

```lua
app:RegisterPage({
  id = "tools.rule-builder",
  category = "tools",
  title = "Rule Builder",
  layout = "custom",
  searchEntries = {
    { id = "rule.create", label = "Create Rule", keywords = { "filter", "new" }, focusID = "create" },
  },
  getSettingCount = function()
    return MyAddon.RuleBuilder:GetRuleCount()
  end,
  getCustomizedCount = function()
    return MyAddon.RuleBuilder:GetChangedRuleCount()
  end,
  getHeight = function() return 560 end,
  render = function(parent, app, page, state, focusID)
    return MyAddon.RuleBuilder:Render(parent, state, focusID)
  end,
  release = function(handle)
    if handle and handle.Release then handle:Release() end
  end,
})
```

Custom pages do not expose host-rendered checkboxes, matrix cells, or table rows
as LibSettingsDesigner controls. Provide `settingCount` / `getSettingCount` and
`customizedCount` / `getCustomizedCount` when the page card, dashboard, or
category badges should show meaningful totals. Aliases accepted by the runtime:
`settingsCount`, `controlCount`, `getSettingsCount`, `getControlCount`,
`changedCount`, and `getChangedCount`.

Use custom pages for table-like database editors first. Do not add a new
generic `datatable` control unless multiple host addons have converged on the
same column, sorting, search, selection, and row-action model.

## Dropdown and MultiDropdown Rules

Dropdowns:

- Use `list` / `options` for static maps.
- Use `orderList` / `order` for deterministic ordering.
- Use `listFunc` / `optionfunc` for runtime lists.
- Use `menuHeight` for large lists.

MultiDropdowns:

- Store selections as boolean maps: `selection[value] == true`.
- Deselect by removing the key or assigning `nil`.
- Keep `setSelectedFunc` and `setSelection` focused on data and lightweight
  runtime preview changes.
- Do not rebuild the settings frame while the menu is open.
- Use a localized `selectAllLabel` string when the menu should provide a checkbox that toggles all options.

## Visibility and Enablement Rules

Use enabled gates to keep rows visible but disabled:

```lua
parentCheck = function()
  return MyAddonDB.profile.enabled == true
end
```

`isEnabled` and `parentCheck` are both disabled-state gates. Prefer
`parentCheck` for child controls depending on a parent toggle; use `isEnabled`
for broader runtime rules such as combat lockdown, missing external data, or a
feature provider not being available. Current runtime calls these gates without
arguments. Only an explicit returned `false` disables the control. Errors or nil
results do not disable it.

Use visibility gates to remove rows/pages:

```lua
visibleWhen = function()
  return MyAddonDB.profile.advanced == true
end
```

Static visibility flags are also supported:

```lua
hidden = true
visible = false
```

Function aliases are supported for both pages and controls:

```lua
isVisible = function(control, app)
  return MyAddon.HasAdvancedMode()
end

hiddenWhen = function(control, app)
  return MyAddon.IsInRestrictedMode()
end
```

Rule of thumb:

| User should see row but not edit | Use `isEnabled` or `parentCheck` |
| Row/page should disappear | Use `visibleWhen` or `hiddenWhen` |

Resolution behavior:

- `hidden == true` hides.
- `visible == false` hides.
- `hiddenWhen(pageOrControl, app) == true` hides.
- Runtime picks one visible function in this priority: `isVisible`,
  `visibleWhen`, then function-valued `visible`.
- If the visible function errors or returns `false`, the object is hidden.

Hidden pages/controls do not render and do not participate in runtime search.

## Notes and Tooltip Rules

Use `description` for short inline text.

Use one of these for hover help:

- `note`
- `notes`
- `richNote`
- `richNotes`

Simple note:

```lua
note = {
  title = "Details",
  text = "Configure layout and behavior in Edit Mode.",
}
```

Rich note:

```lua
notes = {
  {
    title = "Preview",
    blocks = {
      { text = "Use preview mode before entering combat." },
      { type = "spacer", height = 8 },
      { image = "Interface\\AddOns\\MyAddon\\Media\\preview.tga", width = 256, height = 144 },
    },
  },
}
```

Do not hard-code panel height guesses for note behavior. Existing note text uses
rendered `FontString:GetStringHeight()` measurement and removes the final
inter-row gap before sizing the panel so top and bottom padding remain even.

## Wrapper Bridge Pattern

If a host addon has settings wrappers, feature modules should use those wrappers
instead of raw Config/UI calls.

Wrapper layer methods:

```lua
app:RegisterLegacyCategory(category, data)
app:RegisterLegacySection(section, data)
app:RegisterLegacyControl(data)
```

Wrapper example:

```lua
local section = addon.SettingsCreateExpandableSection(category, {
  name = L["myFeature"],
  description = L["myFeatureDesc"],
  configPageID = "interface.my-feature",
  iconKey = "settingspage",
})

addon.SettingsCreateCheckbox(category, {
  var = "myFeatureEnabled",
  text = L["myFeatureEnabled"],
  desc = L["myFeatureEnabledDesc"],
  default = false,
  parentSection = section,
  func = function(value)
    addon.db.myFeatureEnabled = value == true
    addon.RefreshMyFeature()
  end,
})
```

Internal wrapper mapping example:

```lua
app:RegisterLegacyControl({
  parentSection = data.parentSection,
  id = data.id or data.var,
  key = data.var,
  type = "toggle",
  label = data.text,
  description = data.desc,
  default = data.default,
  setValue = data.func,
})
```
