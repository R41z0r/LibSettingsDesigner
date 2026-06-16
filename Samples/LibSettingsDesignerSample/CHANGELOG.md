# Changelog

## Unreleased

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
