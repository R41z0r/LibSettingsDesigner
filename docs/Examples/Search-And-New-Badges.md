<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Search Sources](#search-sources)
- [Adding Search Aliases](#adding-search-aliases)
- [Renamed Setting Example](#renamed-setting-example)
- [New Badge Setup](#new-badge-setup)
- [Page and Control Badges](#page-and-control-badges)
- [Checklist](#checklist)

</details>

## [Search Sources][Top]

Search text is built from the metadata users can reasonably know:

- control label/title/text/id
- description
- key
- keywords/searchtags
- page title
- group title
- category title
- note title/text/blocks

Use aliases when users might search for a different term than the visible label.

## [Adding Search Aliases][Top]

```lua
app:RegisterControl("interface.names", {
  id = "showNicknames",
  key = "showNicknames",
  type = "toggle",
  label = "Show nicknames",
  description = "Use nicknames in group frames.",
  keywords = { "alias", "display name", "social name" },
  default = false,
})
```

Good aliases include:

- old setting names
- common abbreviations
- user slang
- feature module names
- related UI words

Avoid keyword spam. Search aliases should help users find the setting, not turn
every setting into a result for every query.

## [Renamed Setting Example][Top]

When a setting was renamed from "Mouseover bars" to "Fade action bars", keep the
old term as an alias:

```lua
app:RegisterControl("interface.action-bars", {
  id = "fadeActionBars",
  key = "fadeActionBars",
  type = "toggle",
  label = "Fade action bars",
  description = "Fade action bars until hovered.",
  keywords = { "mouseover bars", "bar opacity", "hide bars" },
  default = false,
})
```

## [New Badge Setup][Top]

The app decides whether a tag is new:

```lua
local app = Config:RegisterAddOn(addonName, {
  isNewTag = function(tagID)
    return MyAddonDB.global
      and MyAddonDB.global.newTags
      and MyAddonDB.global.newTags[tagID] == true
  end,
})
```

A page or control declares its tag:

```lua
newTagID = "FadeActionBars"
```

## [Page and Control Badges][Top]

Badge on a page card/detail:

```lua
app:RegisterPage({
  id = "interface.action-bars",
  category = "interface",
  title = "Action Bars",
  description = "Configure action bar behavior.",
  newTagID = "ActionBarsPage",
  order = 100,
})
```

Badge on a specific control:

```lua
app:RegisterControl("interface.action-bars", {
  id = "fadeActionBars",
  key = "fadeActionBars",
  type = "toggle",
  label = "Fade action bars",
  newTagID = "FadeActionBars",
  default = false,
})
```

Use page badges for a new page or feature area. Use control badges for a new
option inside an existing page.

## [Checklist][Top]

- Search aliases are real terms users might type.
- Renamed settings keep old names in `keywords`.
- `newTagID` values are stable and not localized.
- `opts.isNewTag(tagID)` exists before relying on badges.
- Badge state belongs to the host addon, not LibSettingsDesigner.

[//]: # (Links)
[Top]: #Top
