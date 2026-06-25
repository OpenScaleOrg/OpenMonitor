# GitHub Copilot Instructions — OpenMonitor

## Project

OpenMonitor is a C++20 MFC Win32 Windows application (Visual Studio 2022) that monitors
and displays system metrics. Build system: MSBuild. PlatformToolset: v145 (required — has MFC headers).

## Coding Conventions

- MFC dialog classes inherit from `CBaseDialog` (itself from `CDialogEx`)
- String constants via `IDS_*` resource IDs, loaded with `CCommon::LoadText(IDS_FOO, _T(": "))`
- Settings live in `CCommonData`; persisted automatically by `CSettingsHelper`
- Use `CString` for Windows strings, `_T()` macro for string literals
- Never embed non-ASCII in source — use `\uXXXX` in `_T()` literals
- Drawing via `DrawCommon` (GDI) or `D2D1Support` (Direct2D); never raw HDC without RAII

## Architecture Notes

- `OpenMonitor/` — main executable; `stdafx.h` is the precompiled header
- `OpenHardwareMonitorApi/` — C++/CLI wrapper; builds as DLL; CLR required
- Skin system: XML (`skin.xml`) or INI (`skin.ini`) parsed by `SkinFile.cpp`
- Plugin interface: `include/PluginInterface.h` — `IPluginItem` virtual methods

## Build

```powershell
msbuild OpenMonitor.sln /p:Configuration=Release /p:Platform=x64 /m
```

Always build from the solution file, not individual projects.

## MSIX

- `Package.appxmanifest`: Store identity `Name="OpenScale.OpenMonitor"`, `Publisher="CN=7F993A72-..."`
- Startup task Executable must be `OpenMonitor\OpenMonitor.exe` (DesktopBridge adds project-name prefix)

## Do Not Suggest

- Changing PlatformToolset to v143
- Using `std::cout` / `std::cin` (Windows GUI app, no console)
- Raw `malloc`/`free` or `new`/`delete` without RAII
- CMake (project uses MSBuild exclusively)
- Embedding literal Unicode characters in .cpp/.h files
