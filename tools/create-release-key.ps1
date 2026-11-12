# Creates the Android release signing key once and stores it as GitHub Actions secrets.
# The password is typed by you, never printed and never written to the repository.
# ASCII only: Windows PowerShell 5.1 reads BOM-less scripts as ANSI.
$ErrorActionPreference = 'Stop'
$repo = 'YannikFroehlich/frontline-forge'
$alias = 'frontline'
$dir = Join-Path $env:USERPROFILE 'frontline-release-key'
$ks = Join-Path $dir 'frontline-release.keystore'
$keytool = Get-ChildItem 'C:\Program Files\Eclipse Adoptium\jdk-17*\bin\keytool.exe' | Select-Object -First 1 -ExpandProperty FullName

if (Test-Path $ks) {
    throw "Schluessel existiert bereits: $ks`nNicht ueberschreiben: ein neuer Schluessel macht Updates fuer installierte Apps unmoeglich."
}

function Read-Plain($prompt) {
    $s = Read-Host $prompt -AsSecureString
    $b = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
}

Write-Host 'Passwort fuer den Release-Schluessel festlegen. Mindestens 12 Zeichen.'
Write-Host 'Sofort im Passwort-Manager speichern. Ohne Passwort ist der Schluessel wertlos.'
$pass = Read-Plain 'Passwort'
if ($pass.Length -lt 12) { throw 'Passwort zu kurz (mindestens 12 Zeichen).' }
if ($pass -ne (Read-Plain 'Passwort wiederholen')) { throw 'Passwoerter stimmen nicht ueberein.' }

New-Item -ItemType Directory -Force $dir | Out-Null
$env:FL_KEY_PASS = $pass
try {
    # PKCS12 uses one password for store and key, which is what Godot expects.
    & $keytool -genkeypair -keystore $ks -storetype PKCS12 -alias $alias -keyalg RSA -keysize 4096 `
        -validity 10000 -dname 'CN=Frontline Forge' -storepass:env FL_KEY_PASS -keypass:env FL_KEY_PASS
    if ($LASTEXITCODE -ne 0) { throw 'keytool fehlgeschlagen.' }
    $fingerprint = (& $keytool -list -keystore $ks -alias $alias -storepass:env FL_KEY_PASS -v |
        Select-String 'SHA256:').Line.Trim()
} finally {
    Remove-Item Env:FL_KEY_PASS
}

Write-Host 'Lade Secrets nach GitHub ...'
gh secret set ANDROID_KEYSTORE_BASE64 --repo $repo --body ([Convert]::ToBase64String([IO.File]::ReadAllBytes($ks)))
gh secret set ANDROID_KEYSTORE_ALIAS --repo $repo --body $alias
gh secret set ANDROID_KEYSTORE_PASSWORD --repo $repo --body $pass
$pass = $null

Write-Host ''
Write-Host "Fertig. Schluessel: $ks"
Write-Host "Zertifikat $fingerprint"
Write-Host ''
Write-Host 'JETZT SICHERN, an zwei Orten ausserhalb dieses PCs (z. B. USB-Stick und Passwort-Manager):'
Write-Host "  1. Datei $ks"
Write-Host '  2. Das Passwort'
Write-Host 'Geht eines davon verloren, kann keine installierte App mehr aktualisiert werden.'
