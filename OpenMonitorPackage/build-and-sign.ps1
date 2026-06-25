#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Create a self-signed code-signing certificate, build the MSIX package,
    and (optionally) install it for local testing.

.DESCRIPTION
    Run this script once to set up your local dev environment:
      1. Generates a self-signed cert matching the Publisher in Package.appxmanifest
      2. Exports it as OpenMonitor_SelfSigned.pfx (used by the .wapproj)
      3. Installs the cert into Trusted Root + Trusted People so Windows accepts the package
      4. Calls MSBuild to build the MSIX
      5. Optionally launches the .msix for installation

.EXAMPLE
    # From an elevated PowerShell prompt, at the repo root:
    .\OpenMonitorPackage\build-and-sign.ps1

    # Build only (cert already exists):
    .\OpenMonitorPackage\build-and-sign.ps1 -SkipCertCreate

    # Build and install:
    .\OpenMonitorPackage\build-and-sign.ps1 -Install
#>
param(
    [switch]$SkipCertCreate,
    [switch]$Install,
    [string]$Platform    = "x64",
    [string]$Config      = "Release",
    [string]$Publisher   = "CN=OpenMonitor"
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Split-Path -Parent $scriptDir
$pfxPath   = Join-Path $scriptDir "OpenMonitor_SelfSigned.pfx"
$pfxPass   = ""   # Empty password — fine for local dev

# ── 1. Certificate ────────────────────────────────────────────────────────────
if (-not $SkipCertCreate) {
    Write-Host "`n[1/4] Creating self-signed certificate for '$Publisher' ..." -ForegroundColor Cyan

    # Remove any existing cert with the same subject to avoid accumulation
    Get-ChildItem Cert:\CurrentUser\My |
        Where-Object { $_.Subject -eq $Publisher } |
        Remove-Item -Force

    $cert = New-SelfSignedCertificate `
        -Type CodeSigning `
        -Subject $Publisher `
        -KeyUsage DigitalSignature `
        -FriendlyName "OpenMonitor Dev Signing" `
        -CertStoreLocation Cert:\CurrentUser\My `
        -NotAfter (Get-Date).AddYears(3)

    $securePwd = ConvertTo-SecureString -String $pfxPass -Force -AsPlainText
    Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $securePwd | Out-Null

    # Trust the cert so Windows will install the MSIX
    $rootStore   = [System.Security.Cryptography.X509Certificates.X509Store]::new("Root","LocalMachine")
    $peopleStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("TrustedPeople","LocalMachine")
    foreach ($store in @($rootStore, $peopleStore)) {
        $store.Open("ReadWrite")
        $store.Add($cert)
        $store.Close()
    }
    Write-Host "  Certificate thumbprint: $($cert.Thumbprint)" -ForegroundColor Green
    Write-Host "  Exported to: $pfxPath" -ForegroundColor Green
} else {
    Write-Host "`n[1/4] Skipping cert creation (using existing $pfxPath)" -ForegroundColor Yellow
    if (-not (Test-Path $pfxPath)) {
        Write-Error "PFX not found at $pfxPath. Run without -SkipCertCreate first."
    }
}

# ── 2. Locate MSBuild ─────────────────────────────────────────────────────────
Write-Host "`n[2/4] Locating MSBuild ..." -ForegroundColor Cyan
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
    Write-Error "vswhere.exe not found. Install Visual Studio 2022."
}
$msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe |
           Select-Object -First 1
if (-not $msbuild) { Write-Error "MSBuild not found via vswhere." }
Write-Host "  MSBuild: $msbuild" -ForegroundColor Green

# ── 3. Build MSIX ─────────────────────────────────────────────────────────────
Write-Host "`n[3/4] Building MSIX ($Config | $Platform) ..." -ForegroundColor Cyan
$wapproj = Join-Path $scriptDir "OpenMonitorPackage.wapproj"

& $msbuild $wapproj `
    /p:Configuration=$Config `
    /p:Platform=$Platform `
    /p:PackageCertificateKeyFile=$pfxPath `
    /p:PackageCertificatePassword=$pfxPass `
    /p:AppxPackageSigningEnabled=true `
    /p:UapAppxPackageBuildMode=SideloadOnly `
    /m /v:m

if ($LASTEXITCODE -ne 0) { Write-Error "MSBuild failed with exit code $LASTEXITCODE" }

# Find the generated .msix
$outputDir = Join-Path $repoRoot "AppPackages"
$msixFile  = Get-ChildItem $outputDir -Recurse -Filter "*.msix" |
             Sort-Object LastWriteTime -Descending |
             Select-Object -First 1

if ($msixFile) {
    Write-Host "  Output: $($msixFile.FullName)" -ForegroundColor Green
} else {
    Write-Warning "MSIX file not found in $outputDir — check MSBuild output."
}

# ── 4. Install (optional) ─────────────────────────────────────────────────────
if ($Install -and $msixFile) {
    Write-Host "`n[4/4] Installing MSIX ..." -ForegroundColor Cyan
    Add-AppxPackage -Path $msixFile.FullName
    Write-Host "  Installed successfully." -ForegroundColor Green
} elseif ($Install) {
    Write-Warning "Skipping install — MSIX file not found."
} else {
    Write-Host "`n[4/4] Skipping install (pass -Install to install automatically)." -ForegroundColor Yellow
}

Write-Host "`nDone. To install manually, double-click:" -ForegroundColor Cyan
if ($msixFile) { Write-Host "  $($msixFile.FullName)" }
