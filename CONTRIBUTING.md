# Contributing to OpenMonitor

Thank you for taking the time to contribute. This guide covers everything you need to get a change from idea to merged PR.

## Before You Start

- **Bug fixes and small improvements** — open a PR directly. No prior issue required.
- **New features or significant changes** — open an issue first so we can discuss scope and approach before you invest time writing code.
- **Security vulnerabilities** — see [SECURITY.md](SECURITY.md). Do **not** open a public issue.

## Development Environment

### Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| Visual Studio | 2022 (v17+) | C++ compiler, MFC, MSBuild |
| Windows SDK | 10.0.26100+ | Build target |
| MSVC Toolset | v145 | Required for MFC headers — **do not change to v143** |
| GNU Make | any | `choco install make` |
| clang-format | 18+ | Code formatting |
| Python 3 | 3.10+ | pre-commit hooks |

### First-time setup

```powershell
# Clone
git clone https://github.com/OpenScaleOrg/OpenMonitor.git
cd TrafficMonitor

# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Create and trust the local signing certificate
make cert
make cert-trust        # opens an elevated prompt

# Build
make build

# Install and run
make reinstall
make run
```

## Making Changes

### Branching

```
main / master    → always releasable; protected
feature/<name>   → new capability
fix/<name>       → bug fix
docs/<name>      → documentation only
```

Branch from `master`, never commit directly to it.

### Code style

All C++ is formatted with clang-format. Run before committing:

```powershell
make format        # auto-fix
make format-check  # verify only
```

Configuration lives in [.clang-format](.clang-format) — Microsoft style, 4-space indent, 120-column limit.

### Encoding rules — critical

| File type | Encoding | Notes |
|-----------|----------|-------|
| `.rc` / `.rc2` | UTF-16 LE | Never open as UTF-8 |
| `.cpp` / `.h` | UTF-8 no-BOM | MSVC reads as ANSI — use `\uXXXX` for non-ASCII |
| `.ini` (language) | UTF-8 BOM | Key names unchanged; only translate values |

### Commit messages

```
<type>(<scope>): <imperative sentence>

Body if needed — explain WHY, not WHAT.
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:
```
fix(taskbar): correct arrow character encoding in DisplayItem
feat(plugin): expose CPU frequency to plugin API
docs(readme): update download links for v1.87
```

## Pull Requests

1. Run `make check` locally — all three gates (format, lint, tests) must pass
2. Keep PRs focused on one thing. Refactoring + feature in the same PR makes review hard
3. Fill in the PR template completely
4. Link to the issue your PR resolves (`Fixes #123`)

### PR checklist

- [ ] `make build` succeeds with 0 errors and 0 new warnings
- [ ] `make format-check` passes
- [ ] `make test` passes (if touching non-UI logic)
- [ ] Language files updated if adding user-visible strings
- [ ] No literal non-ASCII characters in `.cpp`/`.h` files

## Adding a Language

1. Copy `OpenMonitor/language/English.ini` → `OpenMonitor/language/<Language>.ini`
2. Translate the **values** only — never change key names
3. Save as **UTF-8 with BOM**
4. Test by selecting your language in Options → General

## Plugin Development

See `include/PluginInterface.h` and `PluginDemo/` for the full plugin API. Plugins are Win32 DLLs that export a factory function returning an `IPlugin*`.

## Project Structure

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for a full file tree and architecture overview.

## Getting Help

- **GitHub Discussions** — design questions, "how do I…" questions
- **GitHub Issues** — confirmed bugs and feature requests
- **Email** — suman.debnath@ascentt.com for anything sensitive
