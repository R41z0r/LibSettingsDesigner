# Loading and packaging

Read only the sections relevant to the requested change. Paths in code examples
are relative to the library or host checkout as indicated. `docs/` paths refer
to the skill root documentation. This reference does not authorize external
actions or reading repository instructions outside the active project.

## Repository Map

Runtime layout in this repository:

```text
runtime/
  LibSettingsDesigner/
    LibSettingsDesigner.xml
    LibSettingsDesignerConfig.lua
    LibSettingsDesignerUI.lua
    Assets/
```

Vendored runtime layout inside a host addon:

```text
libs/
  LibSettingsDesigner/
    LibSettingsDesigner.xml
    LibSettingsDesignerConfig.lua
    LibSettingsDesignerUI.lua
    Assets/
```

Expected documentation layout:

```text
docs/
  Home.md
  Architecture.md
  Vendoring.md
  Quick-Start.md
  Field-Glossary.md
  Troubleshooting.md
  Validation.md
  API/
  Elements/
  Examples/
  _Sidebar.md
AGENTS.md
SKILL.md
```

## Vendoring and BigWigsPackager

Host addons must ship their own copy of LibSettingsDesigner. Do not depend on
another addon's copy and do not register LibSettingsDesigner through LibStub.

Recommended host layout:

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

TOC include:

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
```

BigWigsPackager external:

```yaml
externals:
  libs/LibSettingsDesigner:
    url: https://github.com/R41z0r/LibSettingsDesigner.git
    branch: main
    path: runtime/LibSettingsDesigner
```

Use a version tag instead of `branch: main` for reproducible release snapshots.

`path: runtime/LibSettingsDesigner` is required because the repository also
contains docs, samples, and agent guidance. Only the runtime folder belongs in
the host addon's packaged runtime. `Assets/` must be included.

Before opening a pull request for the sample addon release flow, update
`Samples/LibSettingsDesignerSample/CHANGELOG.md` with a short user-facing entry
suitable for CurseForge and Wago. The sample addon's `.pkgmeta` uses that file
as the BigWigsPackager manual changelog.

Using LibStub for unrelated dependencies such as AceLocale or LibSharedMedia is
fine. The LibStub ban applies to LibSettingsDesigner itself.

## Loading Model

The host addon loads the library XML before settings registration code:

```toc
libs\LibSettingsDesigner\LibSettingsDesigner.xml
```

The XML must load the data model before the UI:

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
  <Script file="LibSettingsDesignerConfig.lua" />
  <Script file="LibSettingsDesignerUI.lua" />
</Ui>
```

Then host code reads the APIs from the addon namespace:

```lua
local addonName, addon = ...
local Designer = addon.LibSettingsDesigner
local Config = Designer and Designer.Config
local ConfigUI = Designer and Designer.UI
```
