<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [When to Use It](#when-to-use-it)
- [Custom Page With Search Entries](#custom-page-with-search-entries)
- [Table-Like Record Editors](#table-like-record-editors)
- [Lifecycle Rules](#lifecycle-rules)

</details>

## [Overview][Top]

Custom hosted editors are the escape hatch for settings pages that are too
specialized for normal controls. The host addon renders its own frames inside a
LibSettingsDesigner parent frame, while the library still owns:

- window chrome, theme, density, and sizing
- sidebar navigation
- top-level settings search
- page open/close lifecycle
- release/cleanup on re-render or window hide

Use this before adding a highly specialized generic control to the library.

## [When to Use It][Top]

Good fits:

- rule builders
- nested filter/sorter editors
- record/database management pages
- table-like synced-friend or profile lists
- previews that need several nested rows and row actions

Poor fits:

- simple boolean, number, dropdown, or color settings
- normal ordered lists that fit `reorderlist`
- static help/changelog content that fits `layout = "info"`

## [Custom Page With Search Entries][Top]

```lua
app:RegisterPage({
  id = "friends.sync-database",
  category = "friends",
  title = "Synced Friends Database",
  description = "Inspect, restore, and remove synced friend records.",
  layout = "custom",
  searchEntries = {
    {
      id = "friends.sync.restore",
      label = "Restore Synced Friend",
      keywords = { "restore", "friend", "sync", "database" },
      focusID = "restore",
    },
    {
      id = "friends.sync.delete",
      label = "Delete Synced Friend",
      keywords = { "delete", "remove", "friend", "sync" },
      focusID = "delete",
    },
  },
  getSettingCount = function(app, page)
    return MyAddon.SyncDatabaseEditor:GetVisibleRecordCount()
  end,
  getCustomizedCount = function(app, page)
    return MyAddon.SyncDatabaseEditor:GetPendingChangeCount()
  end,
  getHeight = function(app, page, state)
    return 520
  end,
  render = function(parent, app, page, state, focusID)
    return MyAddon.SyncDatabaseEditor:Render(parent, {
      focusID = focusID,
      density = state and state.density,
      requestLayout = function()
        if state and state.RequestLayout then
          state:RequestLayout()
        end
      end,
    })
  end,
  release = function(handle)
    if handle and handle.Release then
      handle:Release()
    end
  end,
})
```

When a user searches for `restore friend`, the Settings Center search can open
the custom page and pass `focusID = "restore"` to `render`. The host editor then
decides whether to scroll, highlight, open a nested editor state, or select a
record.

The count callbacks are optional but recommended for custom pages that contain
host-rendered checkboxes, table rows, or matrix cells. Without them, page cards
only count registered LibSettingsDesigner controls and a fully custom page will
display `0 settings`.

## [Table-Like Record Editors][Top]

LibSettingsDesigner does not need to own a full `datatable` control for the host
addon to render a table-like editor. Start with a custom page:

```lua
local Editor = {}

function Editor:Render(parent, opts)
  local rows = MyAddon.GetSyncedFriendRows()
  for index, rowData in ipairs(rows) do
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -12 - ((index - 1) * 30))
    row:SetPoint("RIGHT", parent, "RIGHT", -12, 0)
    row:SetHeight(26)

    -- Host owns columns, row actions, icons, and confirmation dialogs.
    MyAddon.RenderFriendRow(row, rowData, opts)
  end

  return self
end

function Editor:Release()
  -- Hide/release retained frames, cancel timers, and clear references.
end
```

If several host addons later need the same column model, search, sorting, and
row actions, a generic `datatable` wrapper can be added on top of this custom
hosting primitive. Do not build the generic table until the repeated shape is
clear.

## [Lifecycle Rules][Top]

- Keep host-addon data and feature logic outside LibSettingsDesigner runtime.
- Return a handle from `render` when the host keeps frame references.
- Implement `release` or `handle:Release()` to clean retained frames and timers.
- Use `state:RequestLayout()` after dynamic height or content changes.
- Provide `searchEntries` for important actions inside custom pages.
- Keep `searchEntries.id` stable and non-localized.
- Use `focusID` as a host-owned routing key, not as a visible label.

[//]: # (Links)
[Top]: #Top
