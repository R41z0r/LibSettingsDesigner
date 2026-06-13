<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Why This Matters](#why-this-matters)
- [Do Not Use Dotted Keys Unless a Wrapper Supports Them](#do-not-use-dotted-keys-unless-a-wrapper-supports-them)
- [Toggle Example](#toggle-example)
- [Slider Example](#slider-example)
- [Color Example](#color-example)
- [Reset and Defaults](#reset-and-defaults)
- [Checklist](#checklist)

</details>

## [Why This Matters][Top]

LibSettingsDesigner's documented simple DB path is direct key access:

```lua
opts.db()[control.key]
```

That is perfect for `profile.enabled`, but not for nested values like
`profile.bars.scale`. For nested values, use explicit getters/setters so the
stored shape, default behavior, and runtime refresh are obvious.

## [Do Not Use Dotted Keys Unless a Wrapper Supports Them][Top]

Avoid this in direct LibSettingsDesigner usage:

```lua
key = "bars.scale"
```

That reads as one literal table key named `"bars.scale"`, unless your host addon
wrapper adds dotted-path behavior before forwarding to LibSettingsDesigner.

Use this instead:

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

## [Toggle Example][Top]

```lua
app:RegisterControl("alerts.core", {
  id = "lowHealthEnabled",
  type = "toggle",
  label = "Low health alert",
  description = "Show an alert when health drops below the configured threshold.",
  default = true,
  getValue = function()
    local alerts = MyAddonDB.profile.alerts
    return alerts and alerts.lowHealthEnabled == true
  end,
  setValue = function(value)
    MyAddonDB.profile.alerts = MyAddonDB.profile.alerts or {}
    MyAddonDB.profile.alerts.lowHealthEnabled = value == true
    MyAddon.RefreshAlerts()
  end,
})
```

## [Slider Example][Top]

```lua
app:RegisterControl("alerts.core", {
  id = "lowHealthThreshold",
  type = "slider",
  label = "Low health threshold",
  min = 5,
  max = 95,
  step = 5,
  suffix = "%",
  default = 35,
  parentCheck = function()
    local alerts = MyAddonDB.profile.alerts
    return alerts and alerts.lowHealthEnabled == true
  end,
  getValue = function()
    local alerts = MyAddonDB.profile.alerts
    return alerts and alerts.lowHealthThreshold or 35
  end,
  setValue = function(value)
    MyAddonDB.profile.alerts = MyAddonDB.profile.alerts or {}
    MyAddonDB.profile.alerts.lowHealthThreshold = tonumber(value) or 35
    MyAddon.RefreshAlerts()
  end,
})
```

## [Color Example][Top]

```lua
app:RegisterControl("alerts.colors", {
  id = "lowHealthColor",
  type = "colorpicker",
  label = "Low health color",
  hasOpacity = true,
  default = { r = 1, g = 0.1, b = 0.1, a = 1 },
  getValue = function()
    local colors = MyAddonDB.profile.colors
    return colors and colors.lowHealth or { r = 1, g = 0.1, b = 0.1, a = 1 }
  end,
  setValue = function(color)
    MyAddonDB.profile.colors = MyAddonDB.profile.colors or {}
    MyAddonDB.profile.colors.lowHealth = color
    MyAddon.RefreshAlertColors()
  end,
})
```

## [Reset and Defaults][Top]

Make sure the default has the same shape as the getter returns.

Good:

```lua
default = 35
getValue = function()
  return MyAddonDB.profile.alerts and MyAddonDB.profile.alerts.lowHealthThreshold or 35
end
```

Risky:

```lua
default = "35"
getValue = function()
  return tonumber(MyAddonDB.profile.alerts.lowHealthThreshold) or 35
end
```

The second example mixes string and number values, which can confuse customized
comparisons and reset behavior.

## [Checklist][Top]

- Getter is nil-safe.
- Setter creates missing nested tables.
- Setter stores the intended type.
- Setter triggers only the needed runtime refresh.
- Default matches the getter's return type.
- Parent/visibility checks read the same nested structure safely.

[//]: # (Links)
[Top]: #Top
