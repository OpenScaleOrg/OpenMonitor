# OpenMonitor — Claude Code Guide

OpenMonitor is a C++20/MFC Windows desktop app that displays real-time network speed,
CPU, RAM, GPU, and hardware temperatures in a floating window and Windows taskbar.

## Architecture

| Project | Type | Output |
|---------|------|--------|
| `OpenMonitor/` | MFC EXE (v145 toolset) | `Bin/x64/Release/OpenMonitor.exe` |
| `OpenHardwareMonitorApi/` | C++/CLI DLL | `Bin/x64/Release/OpenHardwareMonitorApi.dll` |
| `OpenMonitorPackage/` | MSIX .wapproj | `AppPackages/*.msix` |
| `PluginDemo/` | Win32 DLL | Plugin example — excluded from default build |

## Build

```powershell
# Full release build (always build from .sln, not individual .vcxproj)
$vs = 'C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe'
& $vs OpenMonitor.sln /p:Configuration=Release /p:Platform=x64 /m /v:minimal

# Lite build (no hardware monitoring)
& $vs OpenMonitor_Lite.sln /p:'Configuration=Release (lite)' /p:Platform=x64 /m /v:minimal

# MSIX for Store upload (unsigned — Store signs it)
& $vs OpenMonitor.sln /p:Configuration=Release /p:Platform=x64 `
    /p:AppxPackageSigningEnabled=false /p:UapAppxPackageBuildMode=StoreUpload /m

# MSIX for sideloading (self-signed)
& $vs OpenMonitor.sln /p:Configuration=Release /p:Platform=x64 /m
# Then reinstall:
Get-AppxPackage | Where-Object Name -like '*OpenMonitor*' | Remove-AppxPackage
Add-AppxPackage OpenMonitorPackage\AppPackages\*_Test\*.msix
```

## Key Files

- `OpenMonitor/stdafx.h` — Precompiled header; APP_NAME, TASKBAR_WINDOW_NAME, APP_CLASS_NAME defines
- `OpenMonitor/CommonData.h` — Global settings struct (CCommonData)
- `OpenMonitor/DisplayItem.cpp` — Per-item display logic; arrow chars must use `↑`/`↓` (not literal UTF-8)
- `OpenMonitor/OpenMonitorDlg.cpp` — Main floating window dialog
- `OpenMonitor/TaskBarDlg.cpp` — Taskbar embedded window
- `OpenMonitor/GeneralSettingsDlg.cpp` — Options dialog
- `OpenMonitor/language/English.ini` — English strings (key = value; keys unchanged, values translated)
- `OpenMonitorPackage/Package.appxmanifest` — MSIX identity; Publisher must match Store cert
- `OpenMonitorPackage/OpenMonitorPackage.wapproj` — Package project; DLL Link paths use `OpenMonitor\` prefix

## MSIX Identity (Store)

```xml
Name="OpenScale.OpenMonitor"
Publisher="CN=7F993A72-0639-408E-9DB8-365D59E29D5C"
PublisherDisplayName="OpenScale"
```

## Encoding Rules

- `.rc` files are **UTF-16 LE** — read/write with `[System.Text.Encoding]::Unicode`
- `DisplayItem.cpp` and most `.cpp/.h` are **UTF-8 without BOM** — MSVC treats as ANSI
  - Never embed literal Unicode arrows (↑↓) — use `↑` / `↓` in `_T()` strings
- Language `.ini` files use UTF-8 with BOM

## Toolset Notes

- PlatformToolset **v145** → MSVC 14.51 (has `atlmfc/` headers)
- PlatformToolset v143 → MSVC 14.44 (no `atlmfc/`) — do NOT downgrade
- RC AdditionalIncludeDirectories must include `$(VCToolsInstallDir)atlmfc\include`
- `$(SolutionDir)` is wrong when building a `.vcxproj` standalone — always build from `.sln`

## Plugin System

Plugins are Win32 DLLs placed in the `plugins/` folder next to `OpenMonitor.exe`.
They implement `IPluginItem` from `include/PluginInterface.h`.

## Code Conventions

- MFC dialog classes: derive from `CBaseDialog` → `CDialogEx`
- Settings persisted via `CCommonData` (INI-backed)
- String resources: `IDS_*` in `OpenMonitor.rc`, loaded via `CCommon::LoadText()`
- Drawing: Direct2D (`D2D1Support`) and GDI; skin system via XML (`SkinFile.cpp`)
- No `new`/`delete` — prefer MFC handles and RAII wrappers

## Do Not

- Do not add `#pragma once` to `.rc` files
- Do not use PlatformToolset v143 for OpenMonitor or OpenHardwareMonitorApi
- Do not build individual `.vcxproj` files — always use the `.sln`
- Do not embed literal non-ASCII characters in UTF-8-without-BOM source files
- Do not store the PFX in `AppPackages/` (it gets wiped on rebuild) — store in `OpenMonitorPackage/`
- Do not set `UACExecutionLevel` back to `RequireAdministrator` — Store policy 10.6.3 denies
  `allowElevation`; the app must run as standard user (`AsInvoker`)
