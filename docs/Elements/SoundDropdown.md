<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)
- [Preview Behavior](#preview-behavior)

</details>

## [Overview][Top]

SoundDropdown stores one sound value and can preview sounds through a custom
resolver, custom playback function, or LibSharedMedia lookup.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `soundResolver` | function | Converts stored value to playable sound. |
| `previewSoundFunc` | function | Custom preview playback. |
| `previewTooltip` | string | Tooltip text for preview button. |
| `playbackChannel` | string | Sound channel, e.g. `"Master"`. |
| `getPlaybackChannel` | function | Dynamic channel provider. |
| `placeholderText` | string | Empty selection text. |
| `menuHeight` | number | Dropdown menu height. |

## [Example][Top]

```lua
app:RegisterControl("sounds.alerts", {
  id = "readySound",
  key = "readySound",
  type = "sounddropdown",
  label = "Ready sound",
  placeholderText = NONE or "None",
  playbackChannel = "Master",
  previewTooltip = "Preview this sound.",
  soundResolver = function(value)
    return MyAddon.ResolveSound(value)
  end,
  previewSoundFunc = function(value)
    MyAddon.PlaySound(value)
  end,
})
```

## [Preview Behavior][Top]

The preview button tries, in order:

1. `previewSoundFunc`
2. `soundResolver`
3. `LibSharedMedia-3.0` sound lookup
4. Raw stored value

[//]: # (Links)
[Top]: #Top

