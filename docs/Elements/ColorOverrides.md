<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Legacy Alias](#legacy-alias)
- [Migration](#migration)

</details>

## [Legacy Alias][Top]

ColorOverrides is the old name for [ColorPalette](ColorPalette.md).

Existing controls with `type = "coloroverrides"` still work. The runtime maps
that legacy type to `type = "colorpalette"` before rendering.

## [Migration][Top]

For new code, rename the control type:

```lua
type = "colorpalette"
```

No field changes are required. `entries`, `getColor`, `setColor`, `hasOpacity`,
and `colorizeLabel` behave the same as before.

[//]: # (Links)
[Top]: #Top
