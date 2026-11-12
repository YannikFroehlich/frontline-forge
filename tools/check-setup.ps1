# Checks that the local development environment matches docs/SETUP.md.
$ErrorActionPreference = 'SilentlyContinue'
$root = Split-Path $PSScriptRoot -Parent
$wanted = (Get-Content "$root\.godot-version" -Raw).Trim()
$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "$env:LOCALAPPDATA\Android\Sdk" }
$fail = 0

# ASCII only: Windows PowerShell 5.1 reads BOM-less scripts as ANSI.
function Report($name, $ok, $detail, [switch]$Optional) {
    $tag = if ($ok) { 'OK    ' } elseif ($Optional) { 'OFFEN ' } else { 'FEHLT '; $script:fail++ }
    Write-Host "$tag $name  $detail"
}

# Godot: PATH alias from winget, or any godot*.exe on PATH
$godot = (Get-Command godot, godot*.exe | Select-Object -First 1).Source
$gv = if ($godot) { (& $godot --version --headless 2>$null | Select-Object -Last 1) } else { '' }
Report "Godot $wanted" ($gv -like "$wanted.*") $(if ($gv) { "gefunden: $gv" } else { 'nicht im PATH' })

$jdk = Get-ChildItem 'C:\Program Files\Eclipse Adoptium' -Directory -Filter 'jdk-17*' | Select-Object -First 1
Report 'JDK 17' ($null -ne $jdk) $jdk.FullName

Report 'Android SDK' (Test-Path $sdk) $sdk
$packages = @{
    'platform-tools (adb)' = 'platform-tools\adb.exe'
    'build-tools 35.0.1'   = 'build-tools\35.0.1'
    'platform android-35'  = 'platforms\android-35'
    'cmdline-tools'        = 'cmdline-tools\latest\bin\sdkmanager.bat'
    'cmake 3.10.2'         = 'cmake\3.10.2.4988404'
    'ndk 28.1.13356709'    = 'ndk\28.1.13356709'
}
foreach ($p in $packages.GetEnumerator() | Sort-Object Name) {
    Report $p.Name (Test-Path (Join-Path $sdk $p.Value)) ''
}

$templates = "$env:APPDATA\Godot\export_templates\$wanted.stable\android_release.apk"
Report 'Godot Export-Vorlagen' (Test-Path $templates) ''

$adb = Join-Path $sdk 'platform-tools\adb.exe'
$devices = if (Test-Path $adb) { & $adb devices 2>$null | Select-Object -Skip 1 | Where-Object { $_ -match '\tdevice$' } } else { @() }
Report 'Handy per USB' (@($devices).Count -gt 0) "$(@($devices).Count) Geraet(e), erst ab Schritt 3 noetig" -Optional

Write-Host ''
if ($fail -eq 0) { Write-Host 'Alles bereit.' } else { Write-Host "$fail Punkt(e) fehlen. Siehe docs\SETUP.md" }
