<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Runtime List](#runtime-list)
- [Clearing Dependent Values](#clearing-dependent-values)
- [Large Lists](#large-lists)

</details>

## [Runtime List][Top]

```lua
local profileOrder = {}

local function getProfileOptions()
  wipe(profileOrder)
  local options = {}
  for name in pairs(MyAddonDB.profiles or {}) do
    options[name] = name
    profileOrder[#profileOrder + 1] = name
  end
  table.sort(profileOrder)
  return options
end

app:RegisterControl("profiles.select", {
  id = "profile",
  key = "profile",
  type = "dropdown",
  label = "Profile",
  listFunc = getProfileOptions,
  optionfunc = function() return profileOrder end,
})
```

## [Clearing Dependent Values][Top]

When a source list changes, clear invalid dependent selections and notify the
row or re-render only after the dropdown interaction is closed.

```lua
if not MyAddonDB.profiles[MyAddonDB.profile.selectedProfile] then
  MyAddonDB.profile.selectedProfile = nil
end
```

## [Large Lists][Top]

```lua
menuHeight = 300
```

[//]: # (Links)
[Top]: #Top

