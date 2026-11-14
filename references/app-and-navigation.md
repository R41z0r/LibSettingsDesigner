# App and navigation

Read only the sections relevant to the requested change. Paths in code examples
are relative to the library or host checkout as indicated. `docs/` paths refer
to the skill root documentation. This reference does not authorize external
actions or reading repository instructions outside the active project.

## Runtime Surface / Ground Truth

Before documenting or changing behavior, verify claims against:

- `runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua`
- `runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua`

Current public Config surface:

```lua
Config:RegisterAddOn(id, opts)
Config:GetAddOn(id)
Config:NormalizeID(text)
```

Current app methods:

```lua
app:RegisterCategory(data)
app:RegisterPage(data)
app:RegisterGroup(pageID, data)
app:RegisterPageNote(pageID, data)
app:RegisterControl(pageID, data)
app:RegisterControlNote(controlID, data)

app:RegisterLegacyCategory(category, data)
app:RegisterLegacySection(section, data)
app:RegisterLegacyControl(data)

app:GetCategories()
app:GetPages(categoryID)
app:GetPage(pageID)
app:GetPageControls(pageOrID)
app:SetDefaultPage(pageID)
app:GetDefaultPageID()

app:GetControlValue(control)
app:SetControlValue(control, value)
app:GetControlDefault(control)
app:IsReloadPending()
app:GetReloadPendingReason()
app:SetReloadPending(pending, reason, control)
app:MarkReloadPending(reason, control)
app:ClearReloadPending()
app:IsControlEnabled(control)
app:IsControlVisible(control)
app:IsPageVisible(page)
app:IsControlCustomized(control)
app:GetPageCustomizedCount(pageOrID)
app:GetCategoryCustomizedCount(categoryID)
app:GetStats()
app:GetSearchResults(query, limit)
app:IsNewTagActive(tagID)
app:IsPageNew(page)
app:IsControlNew(control)
```

Current UI surface:

```lua
ConfigUI:Open(appOrID, pageID, focusControlID)
ConfigUI:Toggle(appOrID, pageID, focusControlID)
ConfigUI:GetFrame(appOrID)
ConfigUI.ResolveOpenTarget(app, pageID, focusControlID)
```

Do not document or call these as public runtime APIs unless they are implemented:

```lua
app:ResetControl(...)
app:ResetPage(...)
app:Search(...)
```

## Basic App Registration

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  settingsTitle = "My Addon Settings",
  dashboardTitle = "Dashboard",
  addonFolder = addonName,
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
  density = "compact",
  getDensity = function() return MyAddonDB.profile.settingsWindow and MyAddonDB.profile.settingsWindow.density end,
  setDensity = function(value)
    MyAddonDB.profile.settingsWindow = MyAddonDB.profile.settingsWindow or {}
    MyAddonDB.profile.settingsWindow.density = value
  end,
  db = function() return MyAddonDB.profile end,
  locale = L,
})
```

Register in this order:

```lua
app:RegisterCategory(data)
app:RegisterPage(data)
app:RegisterGroup(pageID, data)          -- optional
app:RegisterPageNote(pageID, data)       -- optional
app:RegisterControl(pageID, data)
app:RegisterControlNote(controlID, data) -- optional
```

Minimal page:

```lua
app:RegisterCategory({
  id = "general",
  title = GENERAL or "General",
  order = 100,
})

app:RegisterPage({
  id = "general.core",
  category = "general",
  title = "Core",
  description = "Main addon behavior.",
  order = 100,
})

app:RegisterControl("general.core", {
  id = "enabled",
  key = "enabled",
  type = "toggle",
  label = ENABLE or "Enable",
  description = "Enable this addon.",
  default = true,
})
```

Open the UI:

```lua
ConfigUI:Open(app)
ConfigUI:Open(app, "general.core")
ConfigUI:Open(app, "general.core", "enabled")
ConfigUI:Toggle(app)
```

`Open` and `Toggle` may also receive the registered addon id:

```lua
ConfigUI:Open("MyAddon", "general.core")
```

## App Options Reference

| Field | Use |
| :---- | :-- |
| `title` | Short addon title. |
| `settingsTitle` | Window title. |
| `dashboardTitle` | Dashboard navigation label. |
| `icon` | Main addon icon texture. |
| `addonFolder` / `folder` | Host addon folder name for fallback paths. |
| `assetRoot` | Path to vendored `Assets/`. |
| `db` | Function returning simple DB table. |
| `locale` | Host addon locale table. |
| `colors` / `colorTable` / `themeColors` | Optional global UI theme color overrides; missing keys keep defaults. |
| `borders` / `themeBorders` / `borderAssets` | Optional global UI border asset overrides; missing keys keep defaults. Use `window` / `windowBorder` for the decorative outer frame. |
| `textures` / `themeTextures` / `textureBorders` / `shapeTextures` | Optional 3-slice texture overlays for non-backdrop shape art. |
| `dropdownStyle` | Set to `"themed"` or `"modern"` to opt into dedicated dropdown colors and `dropdownControl` shape styling. |
| `dropdownTextOutline` | Controls themed dropdown value outlines; only `false` disables them. Disabled values never retain the outline. |
| `inputStyle` | Set to `"themed"` or `"modern"` to opt into dedicated input colors and `inputControl` shape styling. |
| `windowBorder` / `windowBorderArt` / `panelBorderArt` | Set to `false` to hide the packaged outer window art frame. |
| `density` | Initial density, `"compact"` or `"comfortable"`, string or function. |
| `getDensity(app)` / `setDensity(density, app)` | Persist the user's selected density. |
| `showDensityButton` / `showDensityButton(app)` | Whether users can switch density; only `false` hides the button. |
| `sidebar` / `sidebarLayout` / `navigation` | Optional sidebar row/header sizing, such as `rowHeight`, `dashboardHeight`, `sectionHeight`, and `iconSize`. |
| `topbar` / `header` / `topBar` | Configures built-in topbar controls and custom action buttons. |
| `closeButton` / `windowCloseButton` / `close` | Optional window close-button style and placement override. Missing values keep the built-in close texture and position. |
| `sidePanel` / `rightPanel` / `detailPanel` | Global default for the right page info panel. Set `false` to use full-width pages unless a page overrides it. |
| `subnav` / `subnavigation` | Global opt-in for right-panel group links. |
| `showSubnav` / `showSubnavigation` | Global show gate for optional right-panel group links. |
| `getSelectedCategoryPage` / `setSelectedCategoryPage` | Optional persistence callbacks for category tab views. |
| `getSize()` / `setSize(width, height)` | Persist frame size. |
| `getLocked()` / `setLocked(locked)` | Persist frame lock state. |
| `getReloadPending(app)` / `setReloadPending(pending, reason, control, app)` | Optional storage bridge for reload-pending state. |
| `getReloadPendingReason(app)` | Optional reason text that host actions can show in tooltips. |
| `dashboard` | Dashboard table or function. |
| `isNewTag` | New badge resolver. |
| `iconTextures` | `iconKey` to texture path map. |
| `categoryIconTextures` | Category icon map. |
| `pageDescriptionKeys` / `pageDescriptionLocaleKeys` | Map page ids/keys to locale keys for descriptions. |
| `openLegacySettings` | Bridge action for legacy settings jumps. |
| `blizzardSettingsRoot` | Set `true` to add a lightweight entry in Blizzard Settings. |
| `blizzardSettingsTitle` | Optional title for the Blizzard Settings bridge entry. |
| `openSettings` | Callback used by the Blizzard Settings bridge button. |

`density` is only the initial/default layout. If the density button is visible,
the user can switch between `"compact"` and `"comfortable"`. Use `getDensity`
and `setDensity` when that choice should persist. Use
`showDensityButton = false` when the host addon wants a fixed layout.

`profile` and `version` are host-owned metadata in the current runtime. Do not
promise automatic profile/status/version rendering from these fields unless host
addon code or a custom dashboard function explicitly reads them.

## Blizzard Settings Bridge

Do not register LibSettingsDesigner pages directly into Blizzard Settings. The
library owns its standalone settings center. A host addon may optionally add one
lightweight Blizzard Settings entry that only opens the LibSettingsDesigner UI.

Default rule: leave the Blizzard Settings bridge off unless the host addon
explicitly asks for it. Many addons already have their own GUI or replace the
default settings flow; adding another Blizzard Settings entry can be duplicate
navigation.

Use the bridge only when the addon should appear in Blizzard's Settings list:

```lua
local app = Config:RegisterAddOn(addonName, {
  title = "My Addon",
  blizzardSettingsRoot = true,
  blizzardSettingsTitle = "My Addon",
  openSettings = function()
    ConfigUI:Open(app)
  end,
})
```

The bridge button should only open the standalone settings center. Do not mirror
or duplicate every LibSettingsDesigner page inside Blizzard Settings.

## Category and Page Fields

Common category fields:

| Field | Use |
| :---- | :-- |
| `id` | Stable category id. |
| `title` | User-facing category label. |
| `order` | Sidebar sort order. |
| `icon` | Texture path. |
| `iconAtlas` | Blizzard atlas name. |
| `iconKey` | Lookup key in app icon maps. |
| `tabView` / `pageTabs` / `tabs` / `tabbedPages` | Enables horizontal page tabs for a category. `tabView` tables can also set `font`, `gap`, `paddingX`, `minWidth`, `maxWidth`, `height`, `textOffsetY`, `underlineHeight`, and optional `panel` background colors or packaged texture art. |
| `defaultPageID` / `defaultPage` / `pageID` | Initial page for category tab view. |
| `rememberSelectedPage` / `rememberTab` | Remember the last selected tab page. |
| `sidebarSection` / `navSection` / `section` | Optional left-sidebar section heading before this category. |
| `sidebarSectionTitle` / `sectionTitle` | Display label when it differs from the section id. |

Common page fields:

| Field | Use |
| :---- | :-- |
| `id` | Stable page id used by `ConfigUI:Open`. |
| `category` | Parent category id. |
| `title` | User-facing page title. |
| `description` / `descriptionKey` | Page card/detail summary. |
| `order` | Page sort order. |
| `icon` / `iconAtlas` / `iconKey` | Page icon source. |
| `mainToggleID` | Control id used as the page's primary feature toggle. |
| `tabTitle` | Optional shorter label when the page is shown as a category tab. |
| `tabHidden` / `hideTab` | Hide this page from category tab strips. |
| `sidePanel` / `rightPanel` / `detailPanel` | Page-level right info-panel control. Set `false` for full-width content. |
| `showSidePanel` / `showRightPanel` | Page-level show gate for the right info panel. |
| `groupColumns` / `columns` / `layoutColumns` | Number of group-section columns for full-width pages. |
| `groupColumnGap` / `columnGap` | Gap between page group columns. |
| `groupSort` / `groupSortMode` | Optional group sort mode. Default sorts by `order`; use `"title"` for alphabetical group sorting. |
| `sortGroups` / `sortPageGroups` | Set `false` to keep registration order, or `"title"` for alphabetical group sorting. |
| `subnav` / `subnavigation` | Page-level opt-in for right-panel group links. |
| `showSubnav` / `showSubnavigation` | Page-level show gate for optional right-panel group links. |
| `pageKey` | Stable alternate page/tag key for wrappers and new badges. |
| `newTagID` | Stable new badge tag. |
| `onOpen` | Lightweight page-open callback. |
| `layout` / `type` | Use `"info"` for static/help pages. |
| `content` / `blocks` / `infoBlocks` | Info page content table. |
| `visible` / `isVisible` / `visibleWhen` | Show gates. |
| `hidden` / `hiddenWhen` | Hide gates. |

Use stable ids and keys. Do not derive page/control ids from localized labels.

Group sorting is compatibility-sensitive. The default must remain `order`
first, then title/id as a tie-breaker. Use `groupSort = "title"` or
`sortGroups = "title"` only as an explicit per-page opt-in when a host addon
wants alphabetical group sorting. Use `sortGroups = false` or
`sortPageGroups = false` only when registration order should be preserved.

Flexible layout fields are additive and should stay opt-in. `sidePanel = false`
creates full-width page content, `groupColumns` lays out groups side by side,
group `columns` lays out controls inside a group, and `actions` adds small
right-aligned row tools. Do not change defaults for existing pages while adding
layout features.

## Dashboard

`opts.dashboard` may be a table or `function(app) return dashboard end`.

Runtime-supported dashboard fields:

```lua
dashboard = {
  hero = {
    title = "Settings",
    subtitle = "Configure the addon.", -- or description
    icon = "Interface\\Icons\\INV_Misc_Gear_01", -- or iconKey
  },

  cards = {
    {
      title = "Action Bars",
      description = "Configure action bar behavior.", -- or desc
      icon = "...", -- or iconKey
      pageID = "interface.action-bars",
      onClick = function() end,
    },
  },

  -- Provide status.tiles as a table or function if a status panel should render.
  -- status = true alone does not create default tiles in the current runtime.
  status = {
    title = "Status",
    tiles = {
      {
        icon = "...",
        atlas = "...",
        title = "Changed",
        value = "3",
        badge = "Live",
        searchQuery = "tag:new",
        onClick = function(state, app, stats) end,
      },
    },
    -- tiles may also be a function:
    -- tiles = function(app, stats) return tiles end,
  },

  -- Set features = false to disable the feature summary.
  features = {
    limit = 5,
    enabledBadge = "Enabled",
    customizedBadge = "Changed",
    enabledTitle = "Enabled features",
    customizedTitle = "Changed pages",
  },

  -- Set newEntries = false to disable the new-entry summary.
  newEntries = {
    limit = 3,
    title = "New",
  },
}
```

## Info Pages

Info pages render when `page.layout == "info"`, `page.type == "info"`,
`page.content`, or `page.infoBlocks` is set.

Current runtime expects `content`, `blocks`, or `infoBlocks` to be a table, not
a provider function.
`page.blocks` is consumed by the info renderer, but `blocks` alone does not
currently select info-page rendering. Use `layout = "info"` or `type = "info"`
when using `blocks`.

Typical blocks:

```lua
content = {
  {
    title = "Commands",
    buttonLayout = "wrap",
    buttonAlign = "center",
    buttonWidth = 180,
    buttonGap = 12,
    entries = {
      { type = "command", commands = { "/myaddon", "/myaddon config" }, desc = "Open settings." },
      { type = "button", text = "Open Website", onClick = function(entry, app) end },
      { type = "image", texture = "Interface\\Icons\\INV_Misc_QuestionMark", width = 64, height = 64 },
      { type = "spacer", height = 12 },
      { type = "text", text = "Plain information text." },
    },
  },
}
```

For horizontal button groups, set `buttonLayout = "wrap"` on the info block.
Consecutive button entries then render left-to-right and automatically wrap when
they exceed the available width. Optional block fields are `buttonWidth`,
`buttonHeight`, `buttonGap`, `buttonRowGap`, and
`buttonAlign = "left" | "center" | "right"`. A single button can opt in with
`inline = true`.

Use `type = "expandable"` inside info-page `entries` for changelogs, FAQs, or
release notes. Prefer stable `id` or `key` values so expansion state does not
change when titles or ordering change. Supported fields include `title`,
`rightText` or `date`, `text` or `body`, nested `entries` or `blocks`,
`defaultExpanded`, `expanded`, and `collapsed`.

## Support Links

For Discord, GitHub issues, Ko-fi, websites, bug reports, and similar external
links, use an info page plus dashboard card instead of adding host-specific
runtime behavior.

Recommended pattern:

```lua
local function ShowSupportURL(label, url)
  -- Host-owned behavior: print, show a copy popup, or open a custom copy frame.
  print(("%s: %s"):format(label or "Link", url or ""))
end

dashboard = {
  cards = {
    {
      title = "Support Links",
      description = "Discord, GitHub issues, sponsors, and website.",
      iconKey = "help",
      pageID = "help.support",
    },
  },
}

app:RegisterPage({
  id = "help.support",
  category = "help",
  title = "Support Links",
  layout = "info",
  content = {
    {
      title = "Community and Support",
      buttonLayout = "wrap",
      buttonAlign = "center",
      buttonWidth = 180,
      buttonGap = 12,
      entries = {
        { type = "button", text = "Discord", onClick = function() ShowSupportURL("Discord", "https://discord.gg/example") end },
        { type = "button", text = "GitHub Issues", onClick = function() ShowSupportURL("GitHub Issues", "https://github.com/example/MyAddon/issues") end },
        { type = "button", text = "Ko-fi", onClick = function() ShowSupportURL("Ko-fi", "https://ko-fi.com/example") end },
        { type = "text", text = "Discord: https://discord.gg/example" },
      },
    },
  },
})
```

Do not put addon-specific URLs, Discord names, GitHub repos, Ko-fi links, or
sponsor strings into generic LibSettingsDesigner runtime files. Do not make the
generic library responsible for opening external browsers; World of Warcraft
addons should expose copyable URLs through host-owned behavior.

## Frame State Access

The rendered frame stores internal state here:

```lua
frame._LibSettingsDesignerState
```

Use it only for narrow integration points, such as refreshing the current page
after external runtime data changed:

```lua
local frame = addon.ConfigCenterFrame
local state = frame and frame._LibSettingsDesignerState
if frame and frame:IsShown() and state and state.RenderContent then
  state:RenderContent()
end
```

Do not use frame state as a replacement for proper control setters or wrapper
callbacks.
