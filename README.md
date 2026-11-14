# Frontline Forge (Arbeitstitel)

Android-Actionspiel: Waffenplattform fährt automatisch eine Bahn entlang, der Spieler lenkt, wählt Tore und baut zwischen den Läufen ein modulares Arsenal auf.

Status: Vertikaler Schnitt (Meilenstein M2). Spielbar ist ein Level mit Boss, dazu:

- modulare Waffen aus Gehäuse, Lauf, Kern und Chip (21 Bauteile)
- Münzen, Freischalten von Bauteilen und Upgrades im Arsenal
- sicherer Spielstand mit Sicherungskopien
- Hauptmenü, Pause, Musik und Soundeffekte

Die Balance-Werte sind noch nicht durch Spieltests abgestimmt. Was vom Projektplan abweicht, steht in dessen Abschnitt 24.

Vollständiges Konzept: [PROJEKTPLAN.md](PROJEKTPLAN.md)

## Installation

Die aktuelle APK liegt unter [Releases](../../releases/latest). Auf Android „Installation aus unbekannten Quellen“ für den Browser beziehungsweise die App erlauben. Spätere Versionen lassen sich direkt in der App aktualisieren.

## Entwicklung

| Branch | Zweck |
|--------|-------|
| `main` | Veröffentlichter Stand. Jeder Merge erzeugt ein Release mit APK |
| `develop` | Sammelstand fertiger Features (Standard-Branch) |
| `feature/<name>`, `fix/<name>` | Arbeit, abgezweigt von `develop`, Pull Request zurück nach `develop` |
| `hotfix/<name>` | Dringende Korrektur, abgezweigt von `main` |

Die Version steht ausschließlich in [version.txt](version.txt) und muss vor jedem Pull Request nach `main` erhöht werden.

Technik: Godot 4 (Version in [.godot-version](.godot-version)), GDScript. Einrichtung: [docs/SETUP.md](docs/SETUP.md).

Testversion bauen und aufs angeschlossene Handy installieren. Sie heißt „Frontline Forge Dev“, hat einen eigenen Paketnamen, läuft neben der Release-Version und prüft nicht auf Updates:

```powershell
godot_console --headless --path . --export-debug "Android Dev" build/frontline-forge-dev.apk
adb install -r build/frontline-forge-dev.apk
```

Tests ausführen (laufen auch automatisch bei jedem Pull Request):

```powershell
godot_console --headless --path . -s tests/run_tests.gd
```

Fremde Inhalte (Musik, Schriften) mit Quelle und Lizenz: [docs/lizenzen.md](docs/lizenzen.md).

Pipelines: `ci.yml` prüft jeden Pull Request (Tests, Probe-Bau, bei Ziel `main` die Versionsnummer). `release.yml` baut nach jedem Merge auf `main` die signierte APK und veröffentlicht sie als GitHub Release.

## Lizenz

Alle Rechte vorbehalten. Der Code ist öffentlich einsehbar, aber nicht zur Weiterverwendung freigegeben.
