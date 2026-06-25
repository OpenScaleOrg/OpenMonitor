# Changelog

All notable changes to OpenMonitor are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For the full upstream history see [UpdateLog/update_log.md](UpdateLog/update_log.md).

---

## [Unreleased]

### Planned
- Microsoft Store listing
- GitHub Pages product site

---

## [1.86.0] — 2026-06-25

### Added
- **MSIX packaging** via Windows Application Packaging Project (Desktop Bridge)
- **Microsoft Store identity** — `OpenScale.OpenMonitor` package name
- **Self-signed certificate** workflow for local sideloading
- **GitHub Pages** product site (`docs/index.html`)
- Comprehensive developer tooling:
  - `.clang-format` and `.clang-tidy` for code quality
  - `.editorconfig` and `.gitattributes` for consistent file handling
  - `.pre-commit-config.yaml` with 5 hook groups
  - `Makefile` with 22 targets covering build, package, test, and code quality
  - AI context files for Claude, Cursor, Windsurf, Copilot, Aider, Gemini
  - `PROJECT_STRUCTURE.md` with full file tree and architecture diagram
  - `tests/` scaffolding with Google Test
  - GitHub Actions workflows: `lint.yml`, `codeql.yml`, `test.yml`
  - Community health files: `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SUPPORT.md`
  - Issue templates for Bug, Feature, Translation, Plugin, Discussion

### Changed
- **Renamed**: TrafficMonitor → **OpenMonitor** throughout all source, manifests, docs, and CI
- **Renamed**: All folders `TrafficMonitor/` → `OpenMonitor/`, skin folders de-Sinicized
- **Fixed**: Arrow characters in taskbar (↑↓) were showing as `â†` due to UTF-8/ANSI mismatch — replaced with `↑`/`↓` escapes
- **Changed**: PlatformToolset `v143` → `v145` (MSVC 14.51) to restore MFC/atlmfc header access
- **Changed**: Default skin font `Microsoft YaHei` → `Segoe UI`
- Language files: all value-side "TrafficMonitor" strings updated to "OpenMonitor"

### Removed
- Chinese-only documentation files (`README_en-us.md`, `Help_en-us.md`, `LICENSE_CN`)
- Chinese issue templates (replaced with English-only)
- Stub `afxres.h` that was shadowing MFC's real header

### Fixed
- `RC2135: file not found: res\TrafficMonitor.ico` after icon rename
- `CBRS_*` MFC constants undefined (caused by stub afxres.h + wrong toolset)
- MSIX startup task `Executable` path — must include `OpenMonitor\` DesktopBridge prefix
- MSIX signing: certificate subject must match `Package.appxmanifest` Publisher
- `OpenHardwareMonitorApi.dll` and `LibreHardwareMonitorLib.dll` not found in MSIX package

---

## [1.85.0] and earlier

See [UpdateLog/update_log.md](UpdateLog/update_log.md) for full upstream changelog.

---

[Unreleased]: https://github.com/OpenScaleOrg/OpenMonitor/compare/v1.86.0...HEAD
[1.86.0]: https://github.com/OpenScaleOrg/OpenMonitor/releases/tag/v1.86.0
