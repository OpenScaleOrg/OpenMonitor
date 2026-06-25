##############################################################################
#  OpenMonitor — Makefile
#
#  Requires GNU Make for Windows (pick one):
#    choco install make
#    winget install GnuWin32.Make
#    scoop install make
#
#  Usage:  make help
#          make build
#          make reinstall
#          make test
##############################################################################

# ── Shell: use PowerShell for every recipe ────────────────────────────────────
.ONESHELL:
SHELL       := pwsh.exe
.SHELLFLAGS := -NoProfile -NonInteractive -Command

# ── Tool paths ────────────────────────────────────────────────────────────────
MSBUILD   := C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe
SIGNTOOL  := C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe
DEVENV    := C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\devenv.exe

# ── Solutions & projects ──────────────────────────────────────────────────────
SOLUTION      := OpenMonitor.sln
SOLUTION_LITE := OpenMonitor_Lite.sln
WAP_PROJ      := OpenMonitorPackage\OpenMonitorPackage.wapproj
TEST_PROJ     := tests\OpenMonitorTests\OpenMonitorTests.vcxproj
TEST_EXE      := tests\OpenMonitorTests\bin\x64\Release\OpenMonitorTests.exe
MANIFEST      := OpenMonitorPackage\Package.appxmanifest

# ── Build configuration ───────────────────────────────────────────────────────
PLATFORM     := x64
CONFIG       := Release
CONFIG_LITE  := Release (lite)
CONFIG_DEBUG := Debug

# ── MSIX / signing ───────────────────────────────────────────────────────────
MSIX_DIR     := OpenMonitorPackage\AppPackages
PFX          := OpenMonitorPackage\OpenMonitor_SelfSigned.pfx
PFX_PASS     := OpenMonitor2026
CERT_SUBJECT := CN=7F993A72-0639-408E-9DB8-365D59E29D5C
PKG_NAME     := OpenScale.OpenMonitor

# ── Output ────────────────────────────────────────────────────────────────────
OUT_DIR      := Bin\x64\Release
EXE          := $(OUT_DIR)\OpenMonitor.exe

# ── Phony targets ─────────────────────────────────────────────────────────────
.PHONY: all help \
        setup \
        build build-lite build-debug build-all rebuild clean \
        package package-store sign install uninstall reinstall \
        test test-build test-run \
        format format-check lint check pre-commit \
        cert cert-trust \
        run open-vs version

.DEFAULT_GOAL := help

# ══════════════════════════════════════════════════════════════════════════════
# HELP
# ══════════════════════════════════════════════════════════════════════════════

help:
	$$g = 'Green'; $$y = 'Yellow'; $$c = 'Cyan'; $$d = 'DarkGray'
	Write-Host ""
	Write-Host "  OpenMonitor — Make targets" -ForegroundColor $$c
	Write-Host "  ──────────────────────────────────────────────" -ForegroundColor $$d
	Write-Host ""
	Write-Host "  BUILD" -ForegroundColor $$y
	Write-Host "    build            Release x64  (EXE + DLLs + MSIX)"
	Write-Host "    build-lite       Release x64 lite  (no temp monitoring)"
	Write-Host "    build-debug      Debug x64"
	Write-Host "    build-all        x64 + x86 + ARM64EC lite builds"
	Write-Host "    rebuild          clean → build"
	Write-Host "    clean            Remove all build artifacts"
	Write-Host ""
	Write-Host "  PACKAGE" -ForegroundColor $$y
	Write-Host "    package          build + sign MSIX for sideloading"
	Write-Host "    package-store    Build .msixupload for Store submission"
	Write-Host "    sign             Re-sign the most recent MSIX"
	Write-Host "    install          Install MSIX to this machine"
	Write-Host "    uninstall        Remove the installed package"
	Write-Host "    reinstall        uninstall → install"
	Write-Host ""
	Write-Host "  TEST" -ForegroundColor $$y
	Write-Host "    test             Build + run unit tests"
	Write-Host "    test-build       Build test project only"
	Write-Host "    test-run         Run already-built tests"
	Write-Host ""
	Write-Host "  CODE QUALITY" -ForegroundColor $$y
	Write-Host "    format           Auto-format C++ files (clang-format)"
	Write-Host "    format-check     Check formatting — no changes written"
	Write-Host "    lint             Run clang-tidy on source files"
	Write-Host "    check            format-check + lint + test  (CI gate)"
	Write-Host "    pre-commit       Run all pre-commit hooks"
	Write-Host ""
	Write-Host "  CERTIFICATES" -ForegroundColor $$y
	Write-Host "    cert             Create new self-signed PFX"
	Write-Host "    cert-trust       Trust cert in LocalMachine stores (elevated)"
	Write-Host ""
	Write-Host "  SETUP" -ForegroundColor $$y
	Write-Host "    setup            First-time dev setup (hooks, cert check, tool audit)"
	Write-Host ""
	Write-Host "  UTILITY" -ForegroundColor $$y
	Write-Host "    run              Launch the installed app"
	Write-Host "    open-vs          Open solution in Visual Studio"
	Write-Host "    version          Print current package version"
	Write-Host ""

# ══════════════════════════════════════════════════════════════════════════════
# SETUP  — run once after cloning
# ══════════════════════════════════════════════════════════════════════════════

setup:
	Write-Host ""
	Write-Host "  OpenMonitor — Developer Setup" -ForegroundColor Cyan
	Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
	Write-Host ""
	$$allOk = $$true
	# ── 1. Required tools ───────────────────────────────────────────────────
	Write-Host "  [1/4] Checking required tools" -ForegroundColor Yellow
	Write-Host ""
	# MSBuild / Visual Studio
	if (Test-Path '$(MSBUILD)') {
	    Write-Host "  ✔ MSBuild (VS 2022 v145)" -ForegroundColor Green
	} else {
	    Write-Host "  ✖ MSBuild not found" -ForegroundColor Red
	    Write-Host "    Install: Visual Studio 2022 → workload 'Desktop development with C++'" -ForegroundColor DarkGray
	    $$allOk = $$false
	}
	# Windows SDK / signtool
	if (Test-Path '$(SIGNTOOL)') {
	    Write-Host "  ✔ signtool.exe (SDK 10.0.26100.0)" -ForegroundColor Green
	} else {
	    Write-Host "  ✖ signtool.exe not found" -ForegroundColor Red
	    Write-Host "    Install: Windows SDK 10.0.26100 (included in VS 2022 installer)" -ForegroundColor DarkGray
	    $$allOk = $$false
	}
	# Python
	$$py = Get-Command python -ErrorAction SilentlyContinue
	if ($$py) {
	    $$pyVer = (python --version 2>&1) -replace 'Python ',''
	    $$pySrc = $$py.Source
	    Write-Host "  ✔ Python $$pyVer  ($$pySrc)" -ForegroundColor Green
	} else {
	    Write-Host "  ✖ Python not found" -ForegroundColor Red
	    Write-Host "    Install: winget install Python.Python.3.12" -ForegroundColor DarkGray
	    $$allOk = $$false
	}
	# LLVM (clang-format / clang-tidy — optional but recommended)
	$$cfmt = Get-Command clang-format -ErrorAction SilentlyContinue
	$$ctid = Get-Command clang-tidy  -ErrorAction SilentlyContinue
	if ($$cfmt -and $$ctid) {
	    $$llvmVer = (clang-format --version 2>&1) -replace 'clang-format version ',''
	    Write-Host "  ✔ LLVM $$llvmVer (clang-format + clang-tidy)" -ForegroundColor Green
	} elseif ($$cfmt -or $$ctid) {
	    Write-Host "  ⚠ LLVM partially installed (both clang-format and clang-tidy needed)" -ForegroundColor Yellow
	    Write-Host "    Install: winget install LLVM.LLVM" -ForegroundColor DarkGray
	} else {
	    Write-Host "  ⚠ LLVM not found (needed for 'make format' and 'make lint')" -ForegroundColor Yellow
	    Write-Host "    Install: winget install LLVM.LLVM" -ForegroundColor DarkGray
	}
	# GNU Make (self-check)
	$$mk = Get-Command make -ErrorAction SilentlyContinue
	if ($$mk) {
	    $$mkVer = (& make --version 2>&1 | Select-Object -First 1) -replace 'GNU Make ',''
	    Write-Host "  ✔ GNU Make $$mkVer" -ForegroundColor Green
	} else {
	    Write-Host "  ⚠ GNU Make not in PATH (needed to use this Makefile from cmd/PS)" -ForegroundColor Yellow
	    Write-Host "    Install: winget install GnuWin32.Make  or  choco install make" -ForegroundColor DarkGray
	}
	Write-Host ""
	# ── 2. pre-commit ───────────────────────────────────────────────────────
	Write-Host "  [2/4] Installing pre-commit" -ForegroundColor Yellow
	Write-Host ""
	$$pc = Get-Command pre-commit -ErrorAction SilentlyContinue
	if ($$pc) {
	    $$pcVer = (pre-commit --version) -replace 'pre-commit ',''
	    Write-Host "  ✔ pre-commit $$pcVer already installed" -ForegroundColor Green
	} else {
	    Write-Host "  → pip install pre-commit ..." -ForegroundColor DarkGray
	    pip install pre-commit --quiet --disable-pip-version-check
	    if ($$LASTEXITCODE -eq 0) {
	        Write-Host "  ✔ pre-commit installed" -ForegroundColor Green
	    } else {
	        Write-Host "  ✖ pip install pre-commit failed — fix Python/pip first" -ForegroundColor Red
	        $$allOk = $$false
	    }
	}
	Write-Host ""
	# ── 3. Git hooks ────────────────────────────────────────────────────────
	Write-Host "  [3/4] Installing git hooks" -ForegroundColor Yellow
	Write-Host ""
	if (-not (Test-Path '.git')) {
	    Write-Host "  ⚠ Not a git repo root — skipping hook install" -ForegroundColor Yellow
	} elseif (Get-Command pre-commit -ErrorAction SilentlyContinue) {
	    pre-commit install
	    if ($$LASTEXITCODE -eq 0) {
	        Write-Host "  ✔ Git hooks installed (.git/hooks/pre-commit)" -ForegroundColor Green
	    } else {
	        Write-Host "  ✖ pre-commit install failed" -ForegroundColor Red
	        $$allOk = $$false
	    }
	} else {
	    Write-Host "  ⚠ pre-commit not available — skipping hook install" -ForegroundColor Yellow
	}
	Write-Host ""
	# ── 4. Self-signed certificate ──────────────────────────────────────────
	Write-Host "  [4/4] Signing certificate for MSIX sideloading" -ForegroundColor Yellow
	Write-Host ""
	if (Test-Path '$(PFX)') {
	    $$pfxObj = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
	        (Resolve-Path '$(PFX)').Path, '$(PFX_PASS)')
	    $$pfxSubj  = $$pfxObj.Subject
	    $$pfxThumb = $$pfxObj.Thumbprint
	    Write-Host "  ✔ PFX found  (subject: $$pfxSubj)" -ForegroundColor Green
	    Write-Host "    Thumbprint: $$pfxThumb" -ForegroundColor DarkGray
	    # Check if already trusted
	    $$trusted = (Get-ChildItem Cert:\LocalMachine\Root | Where-Object Thumbprint -eq $$pfxThumb)
	    if ($$trusted) {
	        Write-Host "  ✔ Certificate is already trusted in LocalMachine\Root" -ForegroundColor Green
	    } else {
	        Write-Host "  ⚠ Certificate is NOT yet trusted — run: make cert-trust" -ForegroundColor Yellow
	        Write-Host "    (Required for 'make install' to work)" -ForegroundColor DarkGray
	    }
	} else {
	    Write-Host "  ⚠ PFX not found at $(PFX)" -ForegroundColor Yellow
	    Write-Host "    Run: make cert    (creates the PFX)" -ForegroundColor DarkGray
	    Write-Host "    Then: make cert-trust  (trusts it — requires elevation)" -ForegroundColor DarkGray
	}
	# ── Summary ─────────────────────────────────────────────────────────────
	Write-Host ""
	Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
	if ($$allOk) {
	    Write-Host "  ✔ Setup complete — you're ready to develop!" -ForegroundColor Green
	} else {
	    Write-Host "  ⚠ Setup done — fix the items marked ✖ above, then re-run 'make setup'" -ForegroundColor Yellow
	}
	Write-Host ""
	Write-Host "  Quick start:" -ForegroundColor DarkGray
	Write-Host "    make build        Build the app" -ForegroundColor DarkGray
	Write-Host "    make package      Build + sign MSIX for sideloading" -ForegroundColor DarkGray
	Write-Host "    make reinstall    Install/update on this machine" -ForegroundColor DarkGray
	Write-Host "    make check        Run all CI checks locally" -ForegroundColor DarkGray
	Write-Host ""

# ══════════════════════════════════════════════════════════════════════════════
# BUILD
# ══════════════════════════════════════════════════════════════════════════════

build:
	Write-Host "▶ build  Release|x64" -ForegroundColor Cyan
	& '$(MSBUILD)' '$(SOLUTION)' `
	    /p:Configuration='$(CONFIG)' `
	    /p:Platform='$(PLATFORM)' `
	    /m /v:minimal /nologo
	if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE }
	Write-Host "✔ Build complete → $(EXE)" -ForegroundColor Green

build-lite:
	Write-Host "▶ build  Release (lite)|x64" -ForegroundColor Cyan
	& '$(MSBUILD)' '$(SOLUTION_LITE)' `
	    '/p:Configuration=$(CONFIG_LITE)' `
	    /p:Platform='$(PLATFORM)' `
	    /m /v:minimal /nologo
	if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE }
	Write-Host "✔ Lite build complete." -ForegroundColor Green

build-debug:
	Write-Host "▶ build  Debug|x64" -ForegroundColor Cyan
	& '$(MSBUILD)' '$(SOLUTION)' `
	    /p:Configuration='$(CONFIG_DEBUG)' `
	    /p:Platform='$(PLATFORM)' `
	    /m /v:minimal /nologo
	if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE }
	Write-Host "✔ Debug build complete." -ForegroundColor Green

build-all:
	Write-Host "▶ build  all platforms (lite)" -ForegroundColor Cyan
	foreach ($$plat in @('x64', 'x86', 'ARM64EC')) {
	    Write-Host "  Platform: $$plat" -ForegroundColor DarkCyan
	    & '$(MSBUILD)' '$(SOLUTION_LITE)' `
	        '/p:Configuration=$(CONFIG_LITE)' `
	        "/p:Platform=$$plat" `
	        /m /v:minimal /nologo
	    if ($$LASTEXITCODE -ne 0) { Write-Error "Build failed on $$plat"; exit 1 }
	}
	Write-Host "✔ All platforms built." -ForegroundColor Green

rebuild: clean build

clean:
	Write-Host "▶ clean" -ForegroundColor Cyan
	$$targets = @(
	    'Bin',
	    'OpenMonitor\x64', 'OpenMonitor\Release', 'OpenMonitor\Debug',
	    'OpenHardwareMonitorApi\x64', 'OpenHardwareMonitorApi\Release',
	    'OpenMonitorPackage\bin', 'OpenMonitorPackage\obj',
	    'OpenMonitorPackage\AppPackages',
	    'tests\OpenMonitorTests\bin', 'tests\OpenMonitorTests\obj'
	)
	foreach ($$d in $$targets) {
	    if (Test-Path $$d) {
	        Remove-Item $$d -Recurse -Force
	        Write-Host "  removed  $$d" -ForegroundColor DarkGray
	    }
	}
	Write-Host "✔ Clean complete." -ForegroundColor Green

# ══════════════════════════════════════════════════════════════════════════════
# PACKAGE
# ══════════════════════════════════════════════════════════════════════════════

package: build sign

package-store:
	Write-Host "▶ package-store  (.msixupload for Store submission)" -ForegroundColor Cyan
	& '$(MSBUILD)' '$(SOLUTION)' `
	    /p:Configuration='$(CONFIG)' `
	    /p:Platform='$(PLATFORM)' `
	    /p:AppxPackageSigningEnabled=false `
	    /p:UapAppxPackageBuildMode=StoreUpload `
	    /m /v:minimal /nologo
	if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE }
	$$f = Get-ChildItem '$(MSIX_DIR)' -Filter '*.msixupload' | Select-Object -First 1
	if ($$f) { Write-Host "✔ Store package: $$($f.FullName)" -ForegroundColor Green }
	else      { Write-Error "msixupload not found in $(MSIX_DIR)"; exit 1 }

sign:
	Write-Host "▶ sign" -ForegroundColor Cyan
	$$msix = Get-ChildItem '$(MSIX_DIR)' -Recurse -Filter '*.msix' `
	    | Sort-Object LastWriteTime -Descending | Select-Object -First 1
	if (-not $$msix) { Write-Error "No MSIX found in $(MSIX_DIR). Run: make build"; exit 1 }
	& '$(SIGNTOOL)' sign /fd SHA256 /a /f '$(PFX)' /p '$(PFX_PASS)' $$msix.FullName
	if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE }
	Write-Host "✔ Signed: $$($msix.FullName)" -ForegroundColor Green

install:
	Write-Host "▶ install" -ForegroundColor Cyan
	$$msix = Get-ChildItem '$(MSIX_DIR)' -Recurse -Filter '*.msix' `
	    | Sort-Object LastWriteTime -Descending | Select-Object -First 1
	if (-not $$msix) { Write-Error "No MSIX found. Run: make package"; exit 1 }
	Add-AppxPackage -Path $$msix.FullName
	if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE }
	$$ver = (Get-AppxPackage | Where-Object Name -like '*OpenMonitor*').Version
	Write-Host "✔ Installed OpenMonitor v$$ver" -ForegroundColor Green

uninstall:
	Write-Host "▶ uninstall" -ForegroundColor Cyan
	$$pkgs = Get-AppxPackage | Where-Object { $$_.Name -like '*OpenMonitor*' -or $$_.Name -like '*OpenScale*' }
	if (-not $$pkgs) { Write-Host "  Nothing to uninstall." -ForegroundColor DarkGray }
	else { $$pkgs | Remove-AppxPackage; Write-Host "✔ Uninstalled." -ForegroundColor Green }

reinstall: uninstall install

# ══════════════════════════════════════════════════════════════════════════════
# TEST
# ══════════════════════════════════════════════════════════════════════════════

test: test-build test-run

test-build:
	Write-Host "▶ test-build" -ForegroundColor Cyan
	if (-not (Test-Path '$(TEST_PROJ)')) {
	    Write-Error "Test project not found: $(TEST_PROJ)"
	    Write-Host "Create it first — see tests/README.md" -ForegroundColor Yellow
	    exit 1
	}
	& '$(MSBUILD)' '$(TEST_PROJ)' `
	    /p:Configuration='$(CONFIG)' `
	    /p:Platform='$(PLATFORM)' `
	    /m /v:minimal /nologo
	if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE }
	Write-Host "✔ Test build complete." -ForegroundColor Green

test-run:
	Write-Host "▶ test-run" -ForegroundColor Cyan
	if (-not (Test-Path '$(TEST_EXE)')) {
	    Write-Error "Test EXE not found. Run: make test-build"
	    exit 1
	}
	& '$(TEST_EXE)' --gtest_output="xml:test_results.xml" --gtest_color=yes
	$$exit = $$LASTEXITCODE
	if   ($$exit -eq 0) { Write-Host "✔ All tests passed." -ForegroundColor Green }
	else                { Write-Host "✖ $$exit test(s) failed." -ForegroundColor Red; exit $$exit }

# ══════════════════════════════════════════════════════════════════════════════
# CODE QUALITY
# ══════════════════════════════════════════════════════════════════════════════

format:
	Write-Host "▶ format  (clang-format --fix)" -ForegroundColor Cyan
	$$files = Get-ChildItem OpenMonitor,OpenHardwareMonitorApi -Recurse -Include *.cpp,*.h `
	    | Where-Object FullName -NotMatch '(tinyxml2|\\x64\\|\\Release\\|\\Debug\\|AppPackages|\.vs)'
	foreach ($$f in $$files) { clang-format -i --style=file $$f.FullName }
	Write-Host "✔ Formatted $$($files.Count) file(s)." -ForegroundColor Green

format-check:
	Write-Host "▶ format-check  (no changes written)" -ForegroundColor Cyan
	$$files = Get-ChildItem OpenMonitor,OpenHardwareMonitorApi -Recurse -Include *.cpp,*.h `
	    | Where-Object FullName -NotMatch '(tinyxml2|\\x64\\|\\Release\\|\\Debug\\|AppPackages|\.vs)'
	$$bad = @()
	foreach ($$f in $$files) {
	    $$xml = clang-format --style=file --output-replacements-xml $$f.FullName
	    if ($$xml -match '<replacement ') { $$bad += $$f.Name }
	}
	if ($$bad.Count -gt 0) {
	    Write-Host "✖ Files needing clang-format:" -ForegroundColor Red
	    $$bad | ForEach-Object { Write-Host "    $$_" -ForegroundColor Red }
	    Write-Host "  Fix with: make format" -ForegroundColor Yellow
	    exit 1
	}
	Write-Host "✔ $$($files.Count) file(s) pass clang-format." -ForegroundColor Green

lint:
	Write-Host "▶ lint  (clang-tidy)" -ForegroundColor Cyan
	$$files = Get-ChildItem OpenMonitor -Recurse -Include *.cpp `
	    | Where-Object FullName -NotMatch '(tinyxml2|stdafx|\\x64\\|\\Release\\|\\Debug\\)'
	$$errors = 0
	foreach ($$f in $$files) {
	    Write-Host "  $$($f.Name)" -ForegroundColor DarkGray
	    clang-tidy $$f.FullName --config-file=.clang-tidy -- `
	        -std=c++20 -DUNICODE -D_UNICODE -DWIN32 -D_WINDOWS `
	        -I'OpenMonitor' -I'include' 2>&1 `
	        | Where-Object { $$_ -match '(warning|error):' } `
	        | ForEach-Object { Write-Host "    $$_" -ForegroundColor Yellow }
	    if ($$LASTEXITCODE -ne 0) { $$errors++ }
	}
	if ($$errors -gt 0) { Write-Host "✖ $$errors file(s) have issues." -ForegroundColor Red; exit 1 }
	Write-Host "✔ Lint clean." -ForegroundColor Green

check: format-check lint test
	Write-Host "✔ All checks passed." -ForegroundColor Green

pre-commit:
	Write-Host "▶ pre-commit  (all files)" -ForegroundColor Cyan
	if (-not (Get-Command pre-commit -ErrorAction SilentlyContinue)) {
	    Write-Error "pre-commit not found. Install: pip install pre-commit"
	    exit 1
	}
	pre-commit run --all-files
	if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE }
	Write-Host "✔ All hooks passed." -ForegroundColor Green

# ══════════════════════════════════════════════════════════════════════════════
# CERTIFICATES
# ══════════════════════════════════════════════════════════════════════════════

cert:
	Write-Host "▶ cert  (create self-signed PFX)" -ForegroundColor Cyan
	$$secpwd = ConvertTo-SecureString -String '$(PFX_PASS)' -Force -AsPlainText
	$$cert = New-SelfSignedCertificate `
	    -Type Custom `
	    -Subject '$(CERT_SUBJECT)' `
	    -KeyUsage DigitalSignature `
	    -FriendlyName 'OpenMonitor Store Sideload' `
	    -CertStoreLocation 'Cert:\CurrentUser\My' `
	    -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3', '2.5.29.19={text}')
	Export-PfxCertificate -Cert $$cert -FilePath '$(PFX)' -Password $$secpwd | Out-Null
	Write-Host "✔ PFX:        $(PFX)"       -ForegroundColor Green
	Write-Host "  Thumbprint: $$($cert.Thumbprint)"
	Write-Host "  Run 'make cert-trust' to install it." -ForegroundColor Yellow

cert-trust:
	Write-Host "▶ cert-trust  (elevates to trust in LocalMachine)" -ForegroundColor Cyan
	$$pfxObj  = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
	    '$(PFX)', '$(PFX_PASS)')
	$$thumb = $$pfxObj.Thumbprint
	$$cmd = "& { " + `
	    "$$cert = Get-Item 'Cert:\CurrentUser\My\$$thumb' -ErrorAction Stop; " + `
	    "foreach ($$s in @('Root','TrustedPeople')) { " + `
	    "$$st = [System.Security.Cryptography.X509Certificates.X509Store]::new($$s,'LocalMachine'); " + `
	    "$$st.Open('ReadWrite'); $$st.Add($$cert); $$st.Close(); " + `
	    "Write-Host ('  Trusted: LocalMachine\' + $$s) } }"
	Start-Process pwsh -ArgumentList "-NoProfile -Command $$cmd" -Verb RunAs -Wait
	Write-Host "✔ Certificate trusted." -ForegroundColor Green

# ══════════════════════════════════════════════════════════════════════════════
# UTILITY
# ══════════════════════════════════════════════════════════════════════════════

run:
	Write-Host "▶ run" -ForegroundColor Cyan
	$$pkg = Get-AppxPackage | Where-Object Name -like '*OpenMonitor*'
	if (-not $$pkg) { Write-Error "Not installed. Run: make install"; exit 1 }
	Start-Process "shell:AppsFolder\$$($pkg.PackageFamilyName)!OpenMonitor"
	Write-Host "✔ Launched." -ForegroundColor Green

open-vs:
	Write-Host "▶ Opening $(SOLUTION) in Visual Studio..." -ForegroundColor Cyan
	Start-Process '$(DEVENV)' '$(SOLUTION)'

version:
	$$xml = [xml](Get-Content '$(MANIFEST)')
	$$id  = $$xml.Package.Identity
	$$p   = $$xml.Package.Properties
	Write-Host ""
	Write-Host "  Package   : $$($id.Name)"           -ForegroundColor Cyan
	Write-Host "  Version   : $$($id.Version)"
	Write-Host "  Publisher : $$($id.Publisher)"
	Write-Host "  Display   : $$($p.DisplayName)"
	Write-Host ""
