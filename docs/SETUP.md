# Entwicklungsumgebung einrichten (Windows)

Einmalig nötig. Dauer etwa 30–45 Minuten, davon das meiste Download. Platzbedarf etwa 8 GB.

Die verwendete Godot-Version steht in [`.godot-version`](../.godot-version). Lokale Entwicklung und Pipeline müssen exakt dieselbe Version nutzen.

## 1. Godot und JDK 17

In PowerShell:

```powershell
winget install --id GodotEngine.GodotEngine --version 4.7.2 --exact
```

```powershell
winget install --id EclipseAdoptium.Temurin.17.JDK --exact
```

Danach PowerShell schließen und neu öffnen, damit die neuen Pfade gelten.

Hinweis: Auf dem Rechner ist zusätzlich Java 8 installiert. Das stört nicht, solange Godot auf JDK 17 zeigt (Schritt 4).

## 2. Android Studio und Android-SDK

Falls Android Studio schon installiert ist, nur den letzten Absatz (Command-line Tools) ausführen.

```powershell
winget install --id Google.AndroidStudio --exact
```

Android Studio einmal starten und den Einrichtungsassistenten mit „Standard“ durchlaufen. Er installiert das SDK nach `%LOCALAPPDATA%\Android\Sdk`.

Dann in Android Studio: **More Actions → SDK Manager → SDK Tools**, Haken bei **Android SDK Command-line Tools (latest)**, **Apply**.

## 3. Exakte SDK-Pakete für Godot

In PowerShell (eine Zeile):

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "build-tools;35.0.1" "platforms;android-35" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;28.1.13356709"
```

Lizenzabfragen mit `y` bestätigen.

## 4. Godot einstellen

1. Godot starten.
2. **Editor → Editor Settings → Export → Android**:
   - **Java SDK Path**: Ordner von JDK 17, normalerweise `C:\Program Files\Eclipse Adoptium\jdk-17.<…>-hotspot`
   - **Android SDK Path**: `C:\Users\<Name>\AppData\Local\Android\Sdk`
3. **Editor → Manage Export Templates → Download and Install** (lädt die Vorlagen für 4.7.2).

## 5. Handy vorbereiten

1. **Einstellungen → Über das Telefon → Build-Nummer** siebenmal antippen. Entwickleroptionen sind jetzt aktiv.
2. **Entwickleroptionen → USB-Debugging** einschalten.
3. Handy per USB anschließen, Abfrage „USB-Debugging zulassen?“ bestätigen.

## 6. Prüfen

Im Projektordner:

```powershell
powershell -ExecutionPolicy Bypass -File tools\check-setup.ps1
```

Alle Zeilen müssen `OK` zeigen.
