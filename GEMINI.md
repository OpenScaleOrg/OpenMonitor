# OpenMonitor — AI Agent Guide

## Project

OpenMonitor is a C++20 / MFC Win32 desktop application for Windows that displays
real-time system metrics (network speed, CPU, RAM, GPU, temperatures) in a floating
window and embedded taskbar widget.

## Repository Layout

```
OpenMonitor/          Main MFC application (~180 source files)
  PdhHardwareQuery/   Windows PDH wrappers (CPU, GPU, disk, frequency)
  tinyxml2/           Embedded XML parser
  language/           Localization INI files (13 languages)
  skins/              XML/BMP skin definitions
  res/                Icons and RC2 resources
OpenHardwareMonitorApi/   C++/CLI bridge DLL to LibreHardwareMonitor
OpenMonitorPackage/       MSIX packaging project (.wapproj)
  Assets/             PNG icons for Store/MSIX
  Package.appxmanifest    MSIX identity and capabilities
PluginDemo/           Sample plugin (excluded from default build)
include/              Public plugin interface header
Bin/                  Build output
tests/                Unit tests (Google Test)
```

## Build Command

```powershell
$vs = 'C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe'
& $vs OpenMonitor.sln /p:Configuration=Release /p:Platform=x64 /m /v:minimal
```

Always build from the `.sln`, never from individual `.vcxproj` files.

## Critical Rules for Agents

1. **Encoding**: `.rc` files are UTF-16 LE. Most `.cpp/.h` are UTF-8 no-BOM (MSVC reads as ANSI).
   Never embed literal non-ASCII in source files — use `\uXXXX` escapes.
2. **Toolset**: PlatformToolset must stay `v145` (has MFC headers). Never change to v143.
3. **Strings**: Arrow chars in `DisplayItem.cpp` must be `_T("↑")` / `_T("↓")`, not literal ↑↓.
4. **MSIX paths**: DesktopBridge prefixes EXE with the vcxproj project name as subfolder.
   Startup task `Executable` must be `OpenMonitor\OpenMonitor.exe` (project-name prefix).
5. **DLLs**: `OpenHardwareMonitorApi.dll` and `LibreHardwareMonitorLib.dll` must be in the
   same folder as `OpenMonitor.exe`.

## Key Source Files

| File | Purpose |
|------|---------|
| `OpenMonitor/stdafx.h` | PCH; APP_NAME / TASKBAR_WINDOW_NAME defines |
| `OpenMonitor/CommonData.h` | Global settings (CCommonData) |
| `OpenMonitor/DisplayItem.cpp` | Per-metric display strings and formatting |
| `OpenMonitor/OpenMonitorDlg.cpp` | Main floating window |
| `OpenMonitor/TaskBarDlg.cpp` | Taskbar embedded panel |
| `OpenMonitor/SkinFile.cpp` | Skin XML/INI parser |
| `OpenMonitorPackage/Package.appxmanifest` | MSIX identity |

## Testing

Run tests from the `tests/` directory:
```powershell
& $vs tests\OpenMonitorTests\OpenMonitorTests.vcxproj /p:Configuration=Release /p:Platform=x64
.\tests\OpenMonitorTests\bin\Release\OpenMonitorTests.exe
```
