# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.86.x (latest) | ✅ |
| < 1.86 | ❌ |

Only the latest release receives security fixes. Update to the current version before filing a report.

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Report security issues privately by emailing **suman.debnath@ascentt.com** with the subject line:

```
[OpenMonitor Security] <brief description>
```

Please include:

- **Description** — what the vulnerability is and where it exists
- **Impact** — what an attacker could achieve
- **Reproduction steps** — exact steps to trigger the issue
- **Environment** — Windows version, OpenMonitor version, standard vs. MSIX install
- **Proof of concept** — code, screenshots, or logs (if safe to share)

## What to Expect

| Timeline | Action |
|----------|--------|
| 48 hours | Acknowledgement of your report |
| 7 days | Initial assessment and severity rating |
| 30 days | Fix released (critical) or scheduled (moderate/low) |
| After fix | Credit in the release notes (unless you prefer anonymity) |

## Scope

**In scope:**
- Privilege escalation beyond the declared `requireAdministrator` manifest
- Code execution via malicious skin files, plugin DLLs, or language INI files
- Arbitrary file read/write via the update mechanism or settings file
- Certificate validation bypass in the MSIX update flow

**Out of scope:**
- Issues requiring physical access to the machine
- Theoretical attacks with no practical exploit path
- Social engineering
- Vulnerabilities in LibreHardwareMonitor or tinyxml2 that are already reported upstream — please report those to their respective projects

## Disclosure Policy

We follow **coordinated disclosure**: we ask for 90 days to release a fix before public disclosure. We will credit researchers by name (or anonymously, per their preference) in the release changelog.
