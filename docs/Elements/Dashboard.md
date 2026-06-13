<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)

</details>

## [Overview][Top]

Dashboard content is provided through `opts.dashboard`. It can be a table or a
function returning a table.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `hero` | table | Main dashboard title/subtitle/icon. |
| `cards` | table | Quick navigation cards. |
| `status` | table | Status tile configuration. |
| `features` | table | Enabled/customized feature lists. |
| `newEntries` | table | New-in-version list. |

## [Example][Top]

```lua
dashboard = function(appInstance)
  return {
    hero = {
      title = "My Addon Settings",
      subtitle = "Configure features and profiles.",
      iconKey = "dashboard",
    },
    cards = {
      {
        title = "Quick Reference",
        description = "Commands and usage notes.",
        iconKey = "help",
        pageID = "help.quick-reference",
      },
    },
    status = {
      title = STATUS or "Status",
      tiles = function(_, stats)
        return {
          {
            title = "Customized",
            value = tostring(stats.customized or 0),
            atlas = "worldquest-tracker-questmarker",
          },
        }
      end,
    },
  }
end
```

[//]: # (Links)
[Top]: #Top

