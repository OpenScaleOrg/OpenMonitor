# Support

## Getting Help

### I found a bug

Please [open a Bug Report](https://github.com/OpenScaleOrg/OpenMonitor/issues/new?template=BugReport_en.yaml).

Before filing:
1. Check that you are on the [latest release](https://github.com/OpenScaleOrg/OpenMonitor/releases/latest)
2. Search [existing issues](https://github.com/OpenScaleOrg/OpenMonitor/issues) — it may already be reported
3. Check [Help.md](Help.md) for common problems and solutions

### I have a question

Use [GitHub Discussions](https://github.com/OpenScaleOrg/OpenMonitor/discussions) for:
- "How do I…" questions
- Skin creation help
- Plugin development questions
- General feedback

### I found a security vulnerability

See [SECURITY.md](SECURITY.md). Do **not** open a public issue.

## Common Issues

| Problem | Solution |
|---------|----------|
| App won't start | Run as Administrator — hardware monitoring requires elevated privileges |
| Temperature shows 0 or N/A | Enable hardware monitoring in Options → General → Hardware |
| Network speed always 0 | Check selected adapter in Options → General → Network |
| MSIX install fails (0x800B010A) | Trust the signing certificate — see [Help.md](Help.md) |
| Wrong arrows (â†) in taskbar | Update to the latest version — fixed in v1.86 |
| Plugin not loading | Place the DLL in the `plugins/` folder next to `OpenMonitor.exe` |

## Versions

| Version | Status |
|---------|--------|
| 1.86.x | ✅ Supported |
| < 1.86 | ❌ Please update |

## Contact

For sensitive matters (security, legal, commercial licensing): **suman.debnath@ascentt.com**

Response time: best-effort, typically within 3 business days.
