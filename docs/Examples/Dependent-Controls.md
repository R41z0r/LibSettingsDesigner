<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Enabled Child](#enabled-child)
- [Hidden Child](#hidden-child)
- [Wrapper Pattern](#wrapper-pattern)

</details>

## [Enabled Child][Top]

The row remains visible but disabled.

```lua
local function featureEnabled()
  return MyAddonDB.profile.enabled == true
end

app:RegisterControl("general.core", {
  id = "scale",
  key = "scale",
  type = "slider",
  label = "Scale",
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  parentCheck = featureEnabled,
})
```

## [Hidden Child][Top]

The row is removed from the rendered page.

```lua
visibleWhen = function()
  return MyAddonDB.profile.advanced == true
end
```

## [Wrapper Pattern][Top]

```lua
local parent = addon.functions.SettingsCreateCheckbox(category, {
  var = "featureEnabled",
  text = L["featureEnabled"],
  default = false,
  parentSection = section,
})

addon.functions.SettingsCreateSlider(category, {
  var = "featureScale",
  text = L["featureScale"],
  min = 0.5,
  max = 2,
  step = 0.05,
  default = 1,
  parentSection = section,
  element = parent and parent.element,
  parentCheck = function()
    return addon.db.featureEnabled == true
  end,
})
```

[//]: # (Links)
[Top]: #Top

