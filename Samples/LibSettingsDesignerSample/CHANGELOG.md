# Changelog

## Unreleased

- Added an opt-in Select All checkbox for MultiDropdown controls.
- Made long grouped dropdown submenus scrollable and applied `menuHeight` consistently to root menus and submenus.
- Fixed `New` badges overlapping compact matrix settings and shortened tab labels by rendering them as non-layout overlays.
- Added a confirmation-backed Defaults button for customized matrix tabs while preserving hidden settings and host reset-action preferences.
- Added opt-in grouped submenus for structured dropdown options without changing existing option lists.
- Show the complete setting label in the hover panel when a row label is truncated, and improve the panel background and heading clarity.
- Fixed scroll buttons not updating when a settings page's scroll range changes.
- Added `New` badges to category page tabs, group tabs, and matrix page tabs when they contain new settings.
- Added opt-in themed dropdown and input styling with dedicated color, border, and shape slots.
- Improved shaped-control hover, disabled-text contrast, customized-count tooltips, and matrix-row hover behavior.
- Added sample coverage for sidebar sections, glow-backed tab panels, two-column tab pages, full-width two-column pages, mixed control columns, and per-setting action menus.
- Added an Atomic sample theme preset with dark panels and cyan accents.
- Added a sample category tab view that remembers the last selected tab page.
- Added a Superellipse sample theme preset with dark cyan colors, shape texture overlays, and optional borderless window styling.
- Reduced repeated backdrop, shape texture, and sample defaults work in the settings UI.
- Kept all supported Retail and Classic Interface versions in the main TOC Interface list.
- Updated sample addon Interface metadata for Retail and Classic game flavors.
- Set the packaged sample addon's TOC version from the generated release tag.
- Moved portal uploads into a dispatched tag run so CurseForge and Wago receive release files.
- Changed the main-branch upload workflow to publish tagged release builds instead of alpha builds.
- Updated the release workflow to use the Node.js 24-compatible checkout action.
- Added the Wago project ID so main-branch package uploads can publish to Wago.
- Added a detailed portal-ready project description for CurseForge and Wago.
- Added BigWigsPackager metadata for publishing the standalone sample addon.
- Added a login chat hint showing how to open the sample settings menu.
- Configured the release workflow to prepare the sample addon as the package root.
- Ensured the prepared sample addon files are included in the packaged ZIP.
