<a name="Top"></a>
<details open>
<summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Required Layout](#required-layout)
- [BigWigsPackager External](#bigwigspackager-external)
- [Sample Addon Packaging](#sample-addon-packaging)
- [Loading](#loading)
- [Asset Root](#asset-root)
- [Do Not Use Shared LibStub](#do-not-use-shared-libstub)
- [Naming](#naming)
- [Install Checklist](#install-checklist)
- [Common Mistakes](#common-mistakes)

</details>

## [Overview][Top]

LibSettingsDesigner is a vendored library. Every addon that uses it should ship
its own copy under that addon's folder.

In this repository, the source runtime lives in `runtime/LibSettingsDesigner/`.
That folder is the only folder that should be copied into a host addon's runtime
tree. The `docs/` folder, `README.md`, `AGENTS.md`, and `SKILL.md` are project
documentation and agent guidance, not in-game addon files.

The library stores itself on the host addon table:

```lua
addon.LibSettingsDesigner.Config
addon.LibSettingsDesigner.UI
```

That means the host addon owns the copy, the loading order, the assets, and any
wrapper helpers around it.

## [Required Layout][Top]

```text
MyAddon/
  MyAddon.toc
  libs/
    LibSettingsDesigner/
      LibSettingsDesigner.xml
      LibSettingsDesignerConfig.lua
      LibSettingsDesignerUI.lua
      Assets/
```

The names matter. Keep the library folder and runtime file names stable, and do
not make the folder a standalone shared dependency.

## [BigWigsPackager External][Top]

Host addons that use BigWigsPackager can vendor LibSettingsDesigner through
`.pkgmeta` instead of committing a local copy of the library.

Use `branch: main` when the host addon should package the latest stable
LibSettingsDesigner runtime:

```yaml
externals:
  libs/LibSettingsDesigner:
    url: https://github.com/R41z0r/LibSettingsDesigner.git
    branch: main
    path: runtime/LibSettingsDesigner
```

The `path` value is required because this repository also contains docs,
samples, and agent guidance. Only `runtime/LibSettingsDesigner` belongs in a
host addon's packaged runtime.

Project policy: `main` must always be releasable. Development work belongs on a
feature branch and reaches `main` only through a reviewed pull request. That
makes `branch: main` suitable as a latest-stable external for addons that want
automatic library updates.

For fully reproducible addon releases, pin a version tag instead:

```yaml
externals:
  libs/LibSettingsDesigner:
    url: https://github.com/R41z0r/LibSettingsDesigner.git
    tag: v1
    path: runtime/LibSettingsDesigner
```

## [Sample Addon Packaging][Top]

The sample addon's own `.pkgmeta` lives in
`Samples/LibSettingsDesignerSample/`. The release workflow copies that sample
addon into the checkout root before running BigWigsPackager, so the packager
sees a normal addon root with a TOC file, `.pkgmeta`, and `CHANGELOG.md`.

The GitHub Actions packaging workflow uploads only when changes are pushed to
`main` or `master`, plus manual `workflow_dispatch` runs. Before portal uploads
are enabled, uncomment and fill `## X-Curse-Project-ID` and `## X-Wago-ID` in
`Samples/LibSettingsDesignerSample/LibSettingsDesignerSample.toc`.

Before opening a sample release pull request, update
`Samples/LibSettingsDesignerSample/CHANGELOG.md` with a short portal-ready
entry. BigWigsPackager uses that file as the manual changelog for CurseForge
and Wago.

## [Loading][Top]

In the host addon's TOC:

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
```

Load the library before files that create settings wrappers, register pages, or
open the settings center.

Recommended order:

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
Locale\enUS.lua
Core.lua
SettingsWrappers.lua
SettingsRegistration.lua
```

The XML should load Config before UI:

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
  <Script file="LibSettingsDesignerConfig.lua" />
  <Script file="LibSettingsDesignerUI.lua" />
</Ui>
```

## [Asset Root][Top]

Pass `assetRoot` when registering the app:

```lua
local app = Config:RegisterAddOn(addonName, {
  assetRoot = "Interface\\AddOns\\MyAddon\\libs\\LibSettingsDesigner\\Assets\\",
})
```

Rules:

- Keep reusable LibSettingsDesigner UI art in `libs/LibSettingsDesigner/Assets`.
- Keep addon-specific feature icons in the host addon's media folder.
- Do not point `assetRoot` at another addon's folder.
- Prefer a trailing slash/backslash in the path so asset concatenation is
  predictable.

## [Do Not Use Shared LibStub][Top]

Do not register LibSettingsDesigner through `LibStub:NewLibrary`.

Reasons:

- Shared LibStub majors can be replaced by another addon's copy.
- UI behavior and asset assumptions are tied to the vendored copy.
- Breaking changes are easier to manage when each addon owns its copy.
- Open settings frames and app state should never upgrade under another addon.
- Wrapper bridges often depend on host-addon-specific assumptions.

Using `LibStub` for unrelated dependencies like AceLocale or LibSharedMedia is
fine. The vendoring rule applies to LibSettingsDesigner itself.

## [Naming][Top]

Use LibSettingsDesigner names everywhere:

```text
LibSettingsDesignerConfig.lua
LibSettingsDesignerUI.lua
addon.LibSettingsDesigner.Config
addon.LibSettingsDesigner.UI
frame._LibSettingsDesignerState
```

## [Install Checklist][Top]

1. Copy `runtime/LibSettingsDesigner/` to `MyAddon/libs/LibSettingsDesigner/`.
2. Include `libs\LibSettingsDesigner\LibSettingsDesigner.xml` in the TOC.
3. Confirm XML loads Config before UI.
4. Register the app after saved variables/locales are available.
5. Set `assetRoot` to the vendored asset folder.
6. Register categories, pages, groups, and controls.
7. Add a slash command or addon button that calls `ConfigUI:Open(app)` or
   `ConfigUI:Toggle(app)`.
8. Run an in-game smoke test.
9. Keep wrapper helpers as the preferred API if the host addon already has
    them.

## [Common Mistakes][Top]

- Including `LibSettingsDesignerConfig.lua` and `LibSettingsDesignerUI.lua`
  directly in the TOC in the wrong order instead of using the XML.
- Forgetting the `Assets/` folder.
- Using `addonFolder = "MyAddon"` but `assetRoot` points to a different addon.
- Registering controls before the app/category/page exists.
- Calling raw LibSettingsDesigner APIs from feature modules even though the host
  addon has wrapper helpers.

[//]: # (Links)
[Top]: #Top
