# LibSettingsDesigner

LibSettingsDesigner is a vendored World of Warcraft settings-center library.
It turns structured metadata into a rendered settings UI through:

```lua
addon.LibSettingsDesigner.Config
addon.LibSettingsDesigner.UI
```

The library is intentionally not a shared LibStub package. Each host addon owns
and ships its own vendored copy.

## Documentation

The maintained documentation lives in the project wiki:

- [LibSettingsDesigner Wiki](https://github.com/R41z0r/LibSettingsDesigner/wiki)
- [Quick Start](https://github.com/R41z0r/LibSettingsDesigner/wiki/Quick-Start)
- [Vendoring](https://github.com/R41z0r/LibSettingsDesigner/wiki/Vendoring)
- [Config API](https://github.com/R41z0r/LibSettingsDesigner/wiki/Config-API)
- [UI API](https://github.com/R41z0r/LibSettingsDesigner/wiki/UI-API)
- [Elements](https://github.com/R41z0r/LibSettingsDesigner/wiki/Elements)
- [Examples](https://github.com/R41z0r/LibSettingsDesigner/wiki/Examples)

The same wiki source is kept in [docs/](docs/Home.md) for repository review and
syncing.

## Runtime

The files to vendor into an addon are in:

```text
runtime/LibSettingsDesigner/
```

Recommended host addon layout:

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

## BigWigsPackager

For host addon release packaging, consume the stable `main` branch as an
external:

```yaml
externals:
  MyAddon/libs/LibSettingsDesigner:
    url: https://github.com/R41z0r/LibSettingsDesigner.git
    branch: main
    path: runtime/LibSettingsDesigner
```

Use a version tag instead of `branch: main` when a host addon needs a fully
reproducible dependency snapshot.

The standalone sample addon includes its own `.pkgmeta` and a GitHub Actions
release workflow packages that sample directory directly. Uploads run only
after changes land on `main` or `master`, or when the workflow is started
manually.

## Sample Addon

A standalone sample addon is available in:

```text
Samples/LibSettingsDesignerSample/
```

Open it in game with:

```text
/lsdsample
```

It demonstrates dashboard cards, status tiles, info pages, controls, search,
new-feature badges, slash commands, and a vendored runtime copy.

## Contributor Notes

- [AGENTS.md](AGENTS.md) defines the repository and AI-agent operating rules.
- [SKILL.md](SKILL.md) is the Codex skill for working with this library.
- Runtime Lua/XML files contain embedded license notices; do not remove them.
- Runtime or sample Lua/XML/assets changes require in-game validation before
  merging to `main`.

## License

LibSettingsDesigner is available under the
[LibSettingsDesigner Vendoring License](LICENSE.md).
