# Frontline Forge (Arbeitstitel)

Android-Actionspiel: Waffenplattform fährt automatisch eine Bahn entlang, der Spieler lenkt, wählt Tore und baut zwischen den Läufen ein modulares Arsenal auf.

Status: Vorproduktion (Meilenstein M0). Noch nicht spielbar.

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

Technik: Godot 4, GDScript. Bauanleitung folgt mit dem ersten Godot-Projekt.

## Lizenz

Alle Rechte vorbehalten. Der Code ist öffentlich einsehbar, aber nicht zur Weiterverwendung freigegeben.
