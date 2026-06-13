<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Fast Triage](#fast-triage)
- [Config or UI is nil](#config-or-ui-is-nil)
- [Assets Are Missing](#assets-are-missing)
- [Control Does Not Save](#control-does-not-save)
- [Reset or Customized Count Looks Wrong](#reset-or-customized-count-looks-wrong)
- [Child Control Should Be Disabled or Hidden](#child-control-should-be-disabled-or-hidden)
- [Dropdown Order Changes](#dropdown-order-changes)
- [Dynamic Dropdown Does Not Refresh](#dynamic-dropdown-does-not-refresh)
- [MultiDropdown Breaks While Clicking](#multidropdown-breaks-while-clicking)
- [Search Does Not Find a Setting](#search-does-not-find-a-setting)
- [New Badge Does Not Show](#new-badge-does-not-show)
- [Open Target Does Not Focus the Control](#open-target-does-not-focus-the-control)
- [In-Game Smoke Test](#in-game-smoke-test)

</details>

## [Fast Triage][Top]

When something is wrong, check these in order:

1. Is `libs\\LibSettingsDesigner\\LibSettingsDesigner.xml` loaded before the
   file that registers settings?
2. Does `addon.LibSettingsDesigner.Config` exist?
3. Does `addon.LibSettingsDesigner.UI` exist?
4. Is the app registered once through `Config:RegisterAddOn(addonName, opts)`?
5. Are category/page/control ids stable and unique?
6. Does the control have a valid `type`?
7. Does the control have either a simple `key`/`var` or explicit getter/setter?
8. Does the control have a `default` when it should support reset/customized
   state?
9. If a wrapper exists, did the feature module use the wrapper instead of raw
   Config/UI calls?

## [Config or UI is nil][Top]

Symptom:

```lua
addon.LibSettingsDesigner == nil
addon.LibSettingsDesigner.Config == nil
addon.LibSettingsDesigner.UI == nil
```

Likely causes:

- The XML file is not included in the TOC.
- The XML file loads after the settings registration file.
- The library was copied to a different path, but the TOC still points to the old
  path.
- The host addon table is not the same table used by the library.

Expected TOC include:

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
```

Expected XML order:

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
  <Script file="LibSettingsDesignerConfig.lua" />
  <Script file="LibSettingsDesignerUI.lua" />
</Ui>
```

## [Assets Are Missing][Top]

Symptoms:

- Border/close/dropdown/collapse art is blank.
- Icons render inconsistently.
- The frame works, but the skin looks broken.

Check `assetRoot`:

```lua
assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\"
```

Rules:

- Keep reusable LibSettingsDesigner UI assets under the vendored library folder.
- Keep addon-specific feature icons in the host addon's media folder.
- Use `iconKey` when you want the app icon map to resolve the texture later.
- Avoid depending on another addon's asset path.

## [Control Does Not Save][Top]

For simple DB values, make sure `opts.db()` returns the table you expect:

```lua
db = function() return MyAddonDB.profile end
```

Then the control should have a direct key:

```lua
app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = "Enabled",
  default = true,
})
```

For nested values, use explicit getter/setter:

```lua
app:RegisterControl("bars.layout", {
  id = "scale",
  type = "slider",
  label = "Scale",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  getValue = function()
    return MyAddonDB.profile.bars and MyAddonDB.profile.bars.scale or 1
  end,
  setValue = function(value)
    MyAddonDB.profile.bars = MyAddonDB.profile.bars or {}
    MyAddonDB.profile.bars.scale = tonumber(value) or 1
    MyAddon.RefreshBars()
  end,
})
```

Do not rely on `key = "bars.scale"` unless the host wrapper explicitly supports
dotted paths. LibSettingsDesigner's documented simple DB behavior is direct
`opts.db()[control.key]` access.

## [Reset or Customized Count Looks Wrong][Top]

Check the default source:

```lua
default = true
```

or:

```lua
dbDefault = function()
  return MyAddon.Defaults.profile.someValue
end
```

Common causes:

- Missing default.
- Default has a different type than the stored value, such as `true` vs
  `"true"`.
- A getter returns a derived value but the default describes the raw stored value.
- A table default is mutated and reused instead of copied by the host addon.
- The control should not count as customized and needs `trackCustomized = false`.

For action-only buttons, customized tracking is usually not meaningful.

## [Child Control Should Be Disabled or Hidden][Top]

Use disabled state when the user should still see the option:

```lua
parentCheck = function()
  return MyAddonDB.profile.enabled == true
end
```

Use visibility when the option should disappear completely:

```lua
visibleWhen = function()
  return MyAddonDB.profile.advanced == true
end
```

Rule of thumb:

| Wanted behavior | Use |
| :-------------- | :-- |
| Show dependency but prevent editing | `isEnabled` or `parentCheck` |
| Remove advanced/irrelevant row | `visibleWhen` or `hiddenWhen` |
| Hide a whole feature page | page-level `visibleWhen` or `hiddenWhen` |

## [Dropdown Order Changes][Top]

Lua table iteration order is not stable. Always provide an order list for
user-facing dropdowns:

```lua
list = {
  LEFT = "Left",
  CENTER = "Center",
  RIGHT = "Right",
},
orderList = { "LEFT", "CENTER", "RIGHT" },
```

For dynamic lists, return both the map and deterministic order:

```lua
listFunc = function()
  return MyAddon.GetProfileLabels()
end,
optionfunc = function()
  return MyAddon.GetProfileOrder()
end,
```

## [Dynamic Dropdown Does Not Refresh][Top]

If the source data changes outside the dropdown's own interaction, refresh the
current page after the data source has changed:

```lua
local frame = addon.ConfigCenterFrame
local state = frame and frame._LibSettingsDesignerState
if frame and frame:IsShown() and state and state.RenderContent then
  state:RenderContent()
end
```

Do not refresh while a dropdown menu is actively being clicked. That can destroy
the currently open menu and produce awkward UI behavior.

## [MultiDropdown Breaks While Clicking][Top]

MultiDropdown selections should update the selection map only. Avoid rebuilding
the settings center from the option click callback.

Good:

```lua
setSelectedFunc = function(value, selected)
  MyAddonDB.profile.roles = MyAddonDB.profile.roles or {}
  MyAddonDB.profile.roles[value] = selected and true or nil
  MyAddon.RefreshRolePreview()
end
```

Risky:

```lua
setSelectedFunc = function(value, selected)
  MyAddonDB.profile.roles[value] = selected
  ConfigUI:Open(app) -- do not rebuild from here
end
```

## [Search Does Not Find a Setting][Top]

Search text is built from label/title/id, description, key, page/category/group
text, notes, and explicit aliases.

Add aliases when users may search for a different word:

```lua
keywords = { "alias", "display name", "nickname" }
```

Use user-facing terms, common abbreviations, and old option names when a setting
was renamed.

## [New Badge Does Not Show][Top]

A badge needs both sides:

```lua
local app = Config:RegisterAddOn(addonName, {
  isNewTag = function(tagID)
    return MyAddon.NewTags and MyAddon.NewTags[tagID] == true
  end,
})
```

and:

```lua
newTagID = "FreshFeature"
```

If the page has a badge but the control does not, check whether `newTagID` is set
on the page, the control, or both depending on the intended display.

## [Open Target Does Not Focus the Control][Top]

Use the exact registered page and control ids:

```lua
ConfigUI:Open(app, "interface.action-bars", "barScale")
```

Do not use labels. These are wrong because they can be localized or renamed:

```lua
ConfigUI:Open(app, "Action Bars", "Scale")
```

If using a combined target like `page.control`, make sure the page id is the
longest matching registered page id and the remaining part is the control id.

## [In-Game Smoke Test][Top]

After documentation or runtime changes, validate the expected user path:

1. Open the settings center from the slash command or addon button.
2. Confirm dashboard/sidebar render without missing art.
3. Open every category with changed docs or changed registration metadata.
4. Change one toggle, one slider, one dropdown, one MultiDropdown, and one input.
5. Reload UI and verify persisted values.
6. Reset a page and verify defaults.
7. Search for a label, a keyword alias, and an old renamed setting name.
8. Hover controls with notes and check panel spacing.
9. Open a page directly with `ConfigUI:Open(app, pageID, controlID)`.
10. Check BugSack/console for Lua errors.

[//]: # (Links)
[Top]: #Top
