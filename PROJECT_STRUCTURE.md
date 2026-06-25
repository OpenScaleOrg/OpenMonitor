# OpenMonitor — Project Structure

## Repository Layout

```
OpenMonitor/                        ← Root
├── OpenMonitor.sln                 Main solution (full: EXE + OHM DLL + MSIX)
├── OpenMonitor_Lite.sln            Lite solution (EXE only, no temp monitoring)
├── CLAUDE.md                       Claude Code guide
├── AGENTS.md                       AI agent guide (OpenAI, Gemini, etc.)
├── GEMINI.md                       Gemini CLI guide
├── .cursorrules                    Cursor AI rules
├── .windsurfrules                  Windsurf AI rules
├── .aider.conf.yml                 Aider configuration
├── .clang-format                   C++ code style
├── .clang-tidy                     C++ static analysis rules
├── .editorconfig                   Editor settings
├── .gitattributes                  Git line-ending rules
├── .pre-commit-config.yaml         Pre-commit hooks
├── .gitignore                      Git ignore rules
│
├── OpenMonitor/                    ─── Main MFC Application ───────────────────
│   ├── OpenMonitor.vcxproj         MSBuild project (PlatformToolset=v145)
│   ├── stdafx.h / stdafx.cpp       Precompiled header (APP_NAME defined here)
│   ├── OpenMonitor.cpp             WinMain / CApp
│   ├── OpenMonitor.rc              Resources (UTF-16 LE)
│   ├── OpenMonitorDlg.cpp/.h       Main floating window dialog
│   ├── TaskBarDlg.cpp/.h           Embedded taskbar widget
│   ├── GeneralSettingsDlg.cpp/.h   Options → General tab
│   ├── CommonData.h/.cpp           Global settings struct (CCommonData)
│   ├── DisplayItem.cpp/.h          Per-metric display string formatting
│   ├── SkinFile.cpp/.h             Skin XML/INI parser
│   ├── DrawCommon.cpp/.h           GDI drawing wrapper
│   ├── D2D1Support.cpp/.h          Direct2D rendering
│   ├── AdapterCommon.cpp/.h        Network adapter enumeration
│   ├── PluginManager.cpp/.h        Plugin DLL loader
│   ├── UpdateHelper.cpp/.h         Auto-update checker
│   │
│   ├── PdhHardwareQuery/           Windows Performance Data Helper
│   │   ├── CPUUsage.cpp/.h         CPU usage via PDH
│   │   ├── CpuFreq.cpp/.h          CPU frequency
│   │   ├── GpuUsage.cpp/.h         GPU usage
│   │   └── DiskUsage.cpp/.h        Disk I/O
│   │
│   ├── tinyxml2/                   Embedded XML parser (third-party, do not lint)
│   │   └── tinyxml2.cpp/.h
│   │
│   ├── language/                   Localization strings
│   │   ├── English.ini             (UTF-8 BOM; keys unchanged, values translated)
│   │   ├── French.ini
│   │   ├── German.ini
│   │   └── ...                     (13 languages total)
│   │
│   ├── skins/                      Built-in skins
│   │   ├── default/                Default skin (BMP + skin.ini)
│   │   └── xml_test/               XML skin example (skin.xml)
│   │
│   └── res/                        Icons and embedded resources
│       ├── OpenMonitor.ico         Application icon (128×128 primary frame)
│       └── OpenMonitor.rc2         Secondary resource includes
│
├── OpenHardwareMonitorApi/         ─── Hardware Monitor DLL ───────────────────
│   ├── OpenHardwareMonitorApi.vcxproj   C++/CLI project (CLR, v145)
│   ├── OpenHardwareMonitorImp.cpp/.h    LibreHardwareMonitor bridge
│   ├── UpdateVisitor.cpp/.h             Hardware update visitor
│   └── LibreHardwareMonitorLib.dll      Third-party .NET library
│
├── OpenMonitorPackage/             ─── MSIX Packaging ─────────────────────────
│   ├── OpenMonitorPackage.wapproj  Windows Application Packaging project
│   ├── Package.appxmanifest        MSIX identity, capabilities, startup task
│   ├── OpenMonitor_SelfSigned.pfx  Self-signed cert for sideloading (password in secrets)
│   └── Assets/                     Store/MSIX icon assets (PNG)
│       ├── Square44x44Logo.png
│       ├── Square150x150Logo.png
│       ├── Wide310x150Logo.png
│       ├── StoreLogo.png           (50×50)
│       └── SplashScreen.png        (620×300)
│
├── PluginDemo/                     ─── Sample Plugin (excluded from build) ────
│   ├── PluginDemo.vcxproj
│   ├── PluginDemo.cpp/.h
│   ├── PluginSystemDate.cpp/.h
│   └── PluginSystemTime.cpp/.h
│
├── include/                        ─── Public Headers ─────────────────────────
│   ├── PluginInterface.h           IPluginItem — plugin contract
│   └── OpenHardwareMonitor/        OHM public API
│       ├── OpenHardwareMonitorApi.h
│       └── OpenHardwareMonitorGlobal.h
│
├── Bin/                            ─── Build Output (not committed) ───────────
│   └── x64/Release/
│       ├── OpenMonitor.exe
│       ├── OpenHardwareMonitorApi.dll
│       └── LibreHardwareMonitorLib.dll
│
├── tests/                          ─── Unit Tests ─────────────────────────────
│   └── OpenMonitorTests/
│       ├── test_main.cpp
│       ├── test_common.cpp
│       ├── test_display_item.cpp
│       └── test_network_adapter.cpp
│
├── .github/
│   ├── workflows/
│   │   ├── main.yml               Release CI (builds + MSIX + GitHub Release)
│   │   ├── lint.yml               Lint CI (clang-format, clang-tidy, markdown)
│   │   ├── codeql.yml             Security analysis (CodeQL)
│   │   └── test.yml               Unit test runner
│   └── ISSUE_TEMPLATE/
│       ├── BugReport_en.yaml
│       └── FeatureRequest_en.yaml
│
├── Screenshots/                    Documentation screenshots
├── UpdateLog/                      Version history (update_log.md)
└── images/                         Marketing / README images
```

## Data Flow

```
Windows API (PDH, WMI, GetIfTable2)
        │
        ▼
CCommonData (poll timer, ~1s interval)
        │
        ├─► Network: CAdapter → bytes sent/received delta
        ├─► CPU:     CPDHQuery (CPUUsage.cpp) or PDH counter
        ├─► Memory:  GlobalMemoryStatusEx
        ├─► GPU:     CGpuUsage (PDH or OHM)
        └─► Temp:    OpenHardwareMonitorApi.dll → LibreHardwareMonitor
                │
                ▼
        CCommonDisplayItem list
                │
        ┌───────┴──────────┐
        ▼                  ▼
CMainDialog            CTaskBarDlg
(floating window)    (taskbar embed)
        │                  │
   DrawCommon /        DrawCommon /
   D2D1Support         D2D1Support
        │
   SkinFile (XML/INI skin)
```

## Key Interfaces

### IPluginItem (`include/PluginInterface.h`)
```cpp
virtual LPCTSTR GetItemName() const = 0;    // display name
virtual LPCTSTR GetItemValue() = 0;         // current reading
virtual void DataRequired() = 0;            // called before GetItemValue
virtual LPCTSTR GetItemUnit() = 0;          // unit string (%, °C, etc.)
virtual void DrawItem(CDC* pDC, ...) = 0;   // optional custom drawing
```

### Skin XML format (`skins/*/skin.xml`)
```xml
<skin>
  <font name="Segoe UI" size="9" />
  <background color="#1E1E1E" />
  <items>
    <item id="net_upload"   x="0"  y="0" w="80" h="20" />
    <item id="net_download" x="80" y="0" w="80" h="20" />
  </items>
</skin>
```

## Build Configurations

| Configuration | Platform | Output | Notes |
|---------------|----------|--------|-------|
| Release | x64 | `Bin/x64/Release/` | Full version with OHM |
| Release (lite) | x64 | `Bin/x64/Release (lite)/` | No temp monitoring |
| Release | x86 | `Bin/Release/` | 32-bit |
| Release | ARM64EC | `Bin/ARM64EC/Release/` | ARM64 EC ABI |
| Debug | x64 | `Bin/x64/Debug/` | Debug symbols |

## MSIX Store Identity

```xml
Name="OpenScale.OpenMonitor"
Publisher="CN=7F993A72-0639-408E-9DB8-365D59E29D5C"
PublisherDisplayName="OpenScale"
Version="1.86.1.0"
```
