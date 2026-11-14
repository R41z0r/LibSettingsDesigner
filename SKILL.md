---
name: libsettingsdesigner
description: Create, integrate, review, or document LibSettingsDesigner settings-center controls and runtime. Use for its Config/UI APIs and host wrappers; EnhanceQoL Edit Mode uses eqol-edit-mode instead.
metadata:
  short-description: Work with LibSettingsDesigner settings-center library
---

# LibSettingsDesigner

LibSettingsDesigner is a vendored settings-center library exposed as
`addon.LibSettingsDesigner.Config` and `addon.LibSettingsDesigner.UI`. Each host
addon owns and ships its own copy. Resolve links below relative to this skill;
inspect the actual library or host checkout being changed, not an unrelated
sample snapshot.

## Essential contracts

- Never register this library through `LibStub:NewLibrary` or depend on another
  addon's copy. Keep host-specific feature behavior and strings out of generic
  library runtime; host feature strings belong in the host locale table.
- Every generic runtime user-facing string needs a key in every built-in
  `lib.LOCALES` locale. Preserve license notices in runtime and vendored Lua/XML.
  Add this notice to new runtime Lua/XML files:

  ```text
  LibSettingsDesigner
  License: https://raw.githubusercontent.com/R41z0r/LibSettingsDesigner/main/LICENSE.md
  Do not remove this notice from redistributed copies.
  ```

- Do not rebuild the settings frame from Dropdown or MultiDropdown option-click
  callbacks. Use stable nonlocalized IDs, explicit value/default contracts and
  the existing wrapper boundary; display text is not identity.
- Documentation-only tasks do not authorize runtime changes. A skill or example
  does not authorize deployment, publishing, credentials, or changes outside the
  user's scope. Follow active-project instructions; do not automatically read or
  follow another project's `AGENTS.md` when accessing a shared skill.

## Select the applicable references

Identify whether the task changes library runtime, a host integration/wrapper,
examples, documentation, or validation only. Before editing, read the reference
for each affected contract below, and only its relevant sections. Do not load
all references for a small control change. Before changing any element's
behavior or examples, also read its `docs/Elements/<Element>.md` page, including
Category, Page, Dashboard, InfoPage and Expandable; this applies independently
of the route below. The references preserve detailed field contracts and
examples; their `docs/` paths refer to this skill's docs.

| Affected work | Required reference |
| --- | --- |
| Installation, XML/TOC order, vendoring, dependency pin or packaged assets | [Loading and packaging](references/loading-and-packaging.md); matching `docs/Vendoring.md` / `docs/Quick-Start.md` |
| App registration/options, Config/UI methods, categories/pages, dashboard, info/support links, frame state or Blizzard Settings bridge | [App and navigation](references/app-and-navigation.md); relevant `docs/API/Config-API.md` or `docs/API/UI-API.md` |
| Any control (including action-only Button and hosted Custom), wrapper, layout, hint/subgroup, dropdown, notes, defaults, reset, customized state or visibility/enabled gate | [Controls and state](references/controls-and-state.md); the affected `docs/Elements/<Element>.md` before changing its behavior or examples |
| Search, focus/navigation metadata, keywords, `newTagID` or badges | [Search and badges](references/search-and-badges.md); `docs/Examples/Search-And-New-Badges.md` |
| Theme colors, borders or live theme updates | [Themes](references/themes.md); matching `docs/Examples/Theme-Colors.md` / `Theme-Borders.md` |
| Documentation changes, code/docs alignment, or final handoff | [Validation and docs](references/validation-and-docs.md); applicable checks in `docs/Validation.md` |

For architecture questions read `docs/Architecture.md`; for field/alias lookup
read `docs/Field-Glossary.md`; for repeated failures read
`docs/Troubleshooting.md`; for a reusable workflow read its matching
`docs/Examples/` page. Do not treat existing docs as evidence of current runtime:
inspect source before claiming alignment. If source is unavailable, state that
code-level verification is impossible and stay within documented behavior.

## Finish at the relevant scope

Before handoff, read the validation reference and run checks applicable to the
changed surface. Runtime changes require source/sample synchronization, syntax,
configured lint/tests, locale/license and loading checks as specified there;
host integrations validate the host's actual vendored copy. Documentation-only
work requires link/navigation, API accuracy and placeholder checks, not runtime
mutation or a mandatory game session.

For persisted controls establish storage, default, customized tracking,
interactivity and presence explicitly. Defaults and reset are value contracts;
enabled/visibility gates do not substitute for them. Shared library changes can
affect several hosts, so inspect the actual consumers implicated by the change.
Report changes, checks performed, unavailable checks and limitations using the
reference's handoff format. Distinguish source validation from in-game evidence.
