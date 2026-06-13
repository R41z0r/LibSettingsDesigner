<a name="Top"></a>
<details open><summary><strong>Contents</strong></summary><br />

- [Overview](#overview)
- [Fields](#fields)
- [Example](#example)

</details>

## [Overview][Top]

CheckboxDropdown combines a boolean setting with one related single-choice
dropdown in the same row.

## [Fields][Top]

| Field | Type | Description |
| :---- | :--- | :---------- |
| `key` | string | Boolean DB key. |
| `dropdownKey` / `dropdownVar` | string | Related dropdown DB key. |
| `dropdownText` | string | Dropdown label. |
| `dropdownList` / `dropdownOptions` | table | Dropdown choices. |
| `dropdownOrder` | table | Dropdown order. |
| `dropdownDefault` | any | Dropdown default value. |
| `dropdownGet` | function | Explicit dropdown getter. |
| `dropdownSet` | function | Explicit dropdown setter. |

## [Example][Top]

```lua
app:RegisterControl("alerts.health", {
  id = "healthAlert",
  key = "healthAlertEnabled",
  type = "checkboxdropdown",
  label = "Health alert",
  dropdownKey = "healthAlertThreshold",
  dropdownText = "Threshold",
  dropdownList = {
    LOW = "Low",
    MEDIUM = "Medium",
    HIGH = "High",
  },
  dropdownOrder = { "LOW", "MEDIUM", "HIGH" },
  default = false,
  dropdownDefault = "MEDIUM",
})
```

[//]: # (Links)
[Top]: #Top

