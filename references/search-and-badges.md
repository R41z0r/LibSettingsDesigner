# Search and badges

Read only the sections relevant to the requested change. Paths in code examples
are relative to the library or host checkout as indicated. `docs/` paths refer
to the skill root documentation. This reference does not authorize external
actions or reading repository instructions outside the active project.

## Search and New Badge Rules

Use search aliases when the visible label is not enough:

```lua
keywords = { "alias", "display name", "old setting name" }
```

Use `app:GetSearchResults(query, limit)` for runtime search. There is no public
`app:Search(query)` method in the current runtime.

Runtime search returns visible controls and explicit page `searchEntries`. It
does not index arbitrary page `keywords` / `searchtags` by itself. Each control
search blob includes:

- control label/title/text/id
- control description/desc
- control key/settingKey
- `control.keywords or control.searchtags`
- owning page title
- owning group title
- owning category title
- control notes

For custom/action pages, use `page.searchEntries` when the search result should
open a page-specific target that is not a normal control:

```lua
searchEntries = {
  { id = "rule.create", label = "Create Rule", keywords = { "filter", "new" }, focusID = "create" },
}
```

If both `keywords` and `searchtags` are set on a control, the current runtime
indexes `keywords`.

Good control tags include old setting names, common abbreviations, slash command
terms, module names, and user-facing terms from older UI.

`tag:new` filters active new controls.

Use `newTagID` only when the app provides `isNewTag`:

```lua
local app = Config:RegisterAddOn(addonName, {
  isNewTag = function(tagID)
    return MyAddon.NewTags
      and MyAddon.NewTags[tagID] == true
      and not (MyAddon.SeenNewTags and MyAddon.SeenNewTags[tagID] == true)
  end,
})
```

Then on a page or control:

```lua
newTagID = "FreshFeature"
```

`newTagID` values must be stable, non-localized identifiers. Prefer explicit
`newTagID` values to avoid accidental badges from ids or DB keys. Current
fallback resolution checks:

- Pages: `page.newTagID`, `page.id`, `page.pageKey`, `page.key`
- Controls: `control.newTagID`, `control.id`, `control.key`

Badge state and seen-state belong to the host addon. A page can use
`onOpen = function(page, app, state)` to mark `page.newTagID` as seen; keep that
callback lightweight and do not rebuild the settings frame from it. Wrappers
should forward `newTagID`, `keywords`, and `searchtags` so feature modules do
not need to call raw Config APIs.
