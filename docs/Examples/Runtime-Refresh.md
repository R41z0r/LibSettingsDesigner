<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Refresh Current Page](#refresh-current-page)
- [When to Use](#when-to-use)
- [When Not to Use](#when-not-to-use)

</details>

## [Refresh Current Page][Top]

Use this after an external editor changes data that affects visible rows.

```lua
local frame = addon.ConfigCenterFrame
if frame and frame.IsShown and frame:IsShown() then
  local state = frame._LibSettingsDesignerState
  if state and state.RenderContent then
    state:RenderContent()
  end
end
```

## [When to Use][Top]

- External standalone editor changed config.
- Runtime data changed available dropdown options.
- A page-level visibility gate changed outside the settings row callback.

## [When Not to Use][Top]

- Inside a MultiDropdown option click.
- While a dropdown menu is open.
- As a substitute for focused row update notifications.

[//]: # (Links)
[Top]: #Top

