<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Custom Control](#custom-control)
- [Custom Page](#custom-page)
- [Search Entries](#search-entries)
- [Lifecycle](#lifecycle)

</details>

## [Overview][Top]

Custom hosting lets a host addon render specialized UI inside
LibSettingsDesigner while the library still owns navigation, search, sizing,
density, theme refresh, and page lifecycle.

Use this for editors that are not simple settings rows, such as rule builders,
record tables, previews, or import tools. Keep host-addon logic in the host
addon; the library only provides the parent frame and lifecycle.

## [Custom Control][Top]

```lua
app:RegisterControl("tools.editor", {
  id = "ruleBuilder",
  type = "custom",
  label = "Rule Builder",
  description = "Create and edit rule-based filters.",
  rowHeight = 420,
  render = function(parent, app, control, state, focusID)
    return MyAddon.RuleBuilder:Render(parent, state, focusID)
  end,
  refresh = function(handle, app, control, state)
    if handle and handle.Refresh then handle:Refresh() end
  end,
  release = function(handle, app, control, state)
    if handle and handle.Release then handle:Release() end
  end,
})
```

`getHeight(app, control, state)` may be used instead of fixed `rowHeight` when
the control height is dynamic.

## [Custom Page][Top]

```lua
app:RegisterPage({
  id = "tools.rule-builder",
  category = "tools",
  title = "Rule Builder",
  layout = "custom",
  getHeight = function(app, page, state)
    return 560
  end,
  render = function(parent, app, page, state, focusID)
    return MyAddon.RuleBuilder:Render(parent, state, focusID)
  end,
  release = function(handle, app, page, state)
    if handle and handle.Release then handle:Release() end
  end,
})
```

Custom pages still get the standard page header, side panel, scroll frame, and
window controls.

## [Search Entries][Top]

Custom pages can provide searchable child entries:

```lua
app:RegisterPage({
  id = "tools.rule-builder",
  category = "tools",
  title = "Rule Builder",
  layout = "custom",
  searchEntries = {
    { id = "rule.create", label = "Create Rule", keywords = { "filter", "new" }, focusID = "create" },
  },
  render = function(parent, app, page, state, focusID)
    return MyAddon.RuleBuilder:Render(parent, state, focusID)
  end,
})
```

Selecting a search entry opens the page and passes `focusID` to `render`.

## [Lifecycle][Top]

The custom `render` callback receives:

```lua
render(parent, app, owner, state, focusID)
```

The returned handle is stored until the content is re-rendered or the settings
window is hidden. Cleanup order:

1. `owner.release(handle, app, owner, state)` when supplied.
2. `handle:Release(app, owner, state)` when the handle provides it.

Use `state:RequestLayout()` after host content changes height or needs a full
layout recalculation.

[//]: # (Links)
[Top]: #Top
