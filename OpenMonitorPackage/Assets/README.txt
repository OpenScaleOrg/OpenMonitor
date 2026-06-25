MSIX Package Asset Icons
========================

Replace the placeholder PNGs in this folder with real artwork before distributing.
Required sizes (all PNG, transparent background recommended):

  Square44x44Logo.png    —  44 x 44  px  (taskbar / small tile)
  Square150x150Logo.png  — 150 x 150 px  (Start Menu medium tile)
  Wide310x150Logo.png    — 310 x 150 px  (Start Menu wide tile)
  StoreLogo.png          —  50 x  50 px  (Microsoft Store listing)
  SplashScreen.png       — 620 x 300 px  (splash on first launch)

Quick way to generate placeholder PNGs for testing
---------------------------------------------------
Run the following PowerShell snippet from this folder:

  Add-Type -AssemblyName System.Drawing
  $sizes = @{
      "Square44x44Logo.png"   = @(44,44)
      "Square150x150Logo.png" = @(150,150)
      "Wide310x150Logo.png"   = @(310,150)
      "StoreLogo.png"         = @(50,50)
      "SplashScreen.png"      = @(620,300)
  }
  foreach ($name in $sizes.Keys) {
      $w,$h = $sizes[$name]
      $bmp = New-Object System.Drawing.Bitmap $w,$h
      $g   = [System.Drawing.Graphics]::FromImage($bmp)
      $g.Clear([System.Drawing.Color]::FromArgb(0,32,64,128))
      $bmp.Save((Join-Path $PWD $name), [System.Drawing.Imaging.ImageFormat]::Png)
      $g.Dispose(); $bmp.Dispose()
      Write-Host "Created $name ($w x $h)"
  }

For Microsoft Store submission, use the Visual Studio
"Image Assets" generator (right-click Package.appxmanifest → Visual Assets tab).
