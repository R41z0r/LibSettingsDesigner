<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Getting the API](#getting-the-api)
- [Methods](#methods)
- [Open](#open)
- [Toggle](#toggle)
- [GetFrame](#getframe)
- [ResolveOpenTarget](#resolveopentarget)
- [Frame State](#frame-state)
- [Size, Lock, and Density Persistence](#size-lock-and-density-persistence)
- [Refresh Rules](#refresh-rules)
- [Examples](#examples)

</details>

## [Overview][Top]

The UI API renders the settings center for an app registered through the Config
API. It owns the visible frame, navigation, dashboard, sidebar, search, page
layout, control widgets, notes, density controls, and open/toggle helpers.

It should render metadata. It should not contain host-addon-specific feature
logic.

## [Getting the API][Top]

```lua
local addonName, addon = ...
local ConfigUI = addon.LibSettingsDesigner and addon.LibSettingsDesigner.UI
```

The UI API expects `addon.LibSettingsDesigner.Config` to be loaded first.

## [Methods][Top]

| Method | Description |
| :----- | :---------- |
| `Open(appOrID, pageID, focusControlID)` | Opens the settings frame. Optionally navigates to a page and focuses a control. |
| `Toggle(appOrID, pageID, focusControlID)` | Opens the frame if hidden, or hides it if already open. |
| `GetFrame(appOrID)` | Returns the existing settings frame for the app, when available. |
| `ResolveOpenTarget(app, pageID, focusControlID)` | Resolves page/control focus shortcuts. |

## [Open][Top]

```lua
ConfigUI:Open(app)
ConfigUI:Open(app, "interface.action-bars")
ConfigUI:Open(app, "interface.action-bars", "barScale")
```

`appOrID` can be the app object or the registered addon id:

```lua
ConfigUI:Open("MyAddon", "general.core")
```

Use stable page/control ids. Do not use localized labels.

Good:

```lua
ConfigUI:Open(app, "interface.action-bars", "barScale")
```

Bad:

```lua
ConfigUI:Open(app, "Action Bars", "Scale")
```

## [Toggle][Top]

```lua
ConfigUI:Toggle(app)
ConfigUI:Toggle(app, "general.core")
```

Use `Toggle` for slash commands or minimap buttons that should close the window
when it is already open.

Use `Open` when the user explicitly clicked a navigation target and you always
want the requested page shown.

## [GetFrame][Top]

```lua
local frame = ConfigUI:GetFrame(app)
```

Use this when a host addon needs to check whether the settings center already
exists or is currently shown.

Example:

```lua
local frame = ConfigUI:GetFrame(app)
if frame and frame:IsShown() then
  -- Settings window is already open.
end
```

## [ResolveOpenTarget][Top]

`ResolveOpenTarget(app, pageID, focusControlID)` resolves page/control shortcuts
used by `Open`.

A direct page and control id is clearest:

```lua
ConfigUI:Open(app, "interface.action-bars", "barScale")
```

If a combined target is used, the resolver can split the longest matching page
id and use the remaining part as the control id. Keep ids unambiguous.

## [Frame State][Top]

The rendered frame stores internal state at:

```lua
frame._LibSettingsDesignerState
```

Use this only for narrow integration points, such as refreshing the currently
rendered page after external runtime data changed:

```lua
local frame = addon.ConfigCenterFrame
local state = frame and frame._LibSettingsDesignerState
if frame and frame:IsShown() and state and state.RenderContent then
  state:RenderContent()
end
```

Do not use frame state as a replacement for proper setters, wrapper callbacks,
or control registration.

## [Size, Lock, and Density Persistence][Top]

The app can provide persistence callbacks:

```lua
local app = Config:RegisterAddOn(addonName, {
  getSize = function()
    local db = MyAddonDB.profile.settingsWindow or {}
    return db.width, db.height
  end,
  setSize = function(width, height)
    MyAddonDB.profile.settingsWindow = MyAddonDB.profile.settingsWindow or {}
    MyAddonDB.profile.settingsWindow.width = width
    MyAddonDB.profile.settingsWindow.height = height
  end,
  getLocked = function()
    return MyAddonDB.profile.settingsWindow
      and MyAddonDB.profile.settingsWindow.locked == true
  end,
  setLocked = function(locked)
    MyAddonDB.profile.settingsWindow = MyAddonDB.profile.settingsWindow or {}
    MyAddonDB.profile.settingsWindow.locked = locked == true
  end,
  getDensity = function()
    return MyAddonDB.profile.settingsWindow
      and MyAddonDB.profile.settingsWindow.density
  end,
  setDensity = function(value)
    MyAddonDB.profile.settingsWindow = MyAddonDB.profile.settingsWindow or {}
    MyAddonDB.profile.settingsWindow.density = value == "compact" and "compact" or "comfortable"
  end,
})
```

Use these callbacks instead of hard-coding frame size, lock, or density state
inside the library. `density` sets the initial layout; `getDensity` and
`setDensity` persist the user's compact/comfortable choice. Set
`showDensityButton = false` when the density switch should not be shown.

## [Refresh Rules][Top]

Use a current-page refresh when external state changes the options or visibility
of already-rendered rows:

```lua
local frame = addon.ConfigCenterFrame
local state = frame and frame._LibSettingsDesignerState
if frame and frame:IsShown() and state and state.RenderContent then
  state:RenderContent()
end
```

Good use cases:

- a standalone editor changed data used by visible rows
- available dropdown options changed outside the dropdown interaction
- a page-level visibility gate changed outside a settings callback

Avoid this:

- inside a MultiDropdown option click
- while a dropdown menu is open
- as a substitute for a focused row update or runtime feature refresh

## [Examples][Top]

Open from a slash command:

```lua
SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function(input)
  input = strtrim(input or "")
  if input == "bars" then
    ConfigUI:Open(app, "interface.action-bars")
  else
    ConfigUI:Toggle(app)
  end
end
```

Open a specific control from a warning prompt:

```lua
MyAddon.ShowFixButton = function()
  ConfigUI:Open(app, "general.core", "enabled")
end
```

Refresh after external data import:

```lua
MyAddon.ImportProfile = function(imported)
  MyAddonDB.profile = imported

  local frame = addon.ConfigCenterFrame
  local state = frame and frame._LibSettingsDesignerState
  if frame and frame:IsShown() and state and state.RenderContent then
    state:RenderContent()
  end
end
```

[//]: # (Links)
[Top]: #Top
