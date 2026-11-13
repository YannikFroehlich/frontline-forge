# Lizenzen fremder Inhalte

Jede fremde Datei im Spiel steht hier mit Quelle und Lizenz (Projektplan 11.4). Erlaubt sind CC0 und CC-BY. Nicht erlaubt sind GPL und Lizenzen mit NC, ND oder SA.

## Musik

Alle Stücke stammen von Juhani Junkala (SubspaceAudio) und stehen unter **CC0 1.0** (gemeinfrei, keine Namensnennung nötig). Lizenz am 13.11.2026 auf den Quellseiten geprüft.

| Datei in `assets/audio/music/` | Einsatz | Originaldatei | Quelle |
|---|---|---|---|
| `menu_theme.ogg` | Hauptmenü | `Juhani Junkala - JRPG Theme [Loop Ready].ogg` | https://opengameart.org/content/jrpg-trailer-theme |
| `level_army_approaching.ogg` | Level | `Action2 - Army Approaching.ogg` | https://opengameart.org/content/jrpg-pack-5-action |
| `boss_epic_battle.ogg` | Boss | `Juhani Junkala - Epic Boss Battle [Seamlessly Looping].wav` | https://opengameart.org/content/boss-battle-music |

Bearbeitung: `boss_epic_battle.ogg` wurde mit ffmpeg von WAV nach Ogg Vorbis (Qualität 5) umgewandelt. Die anderen Dateien sind unverändert, nur umbenannt.

## Schriften

Siehe `assets/fonts/README.md`: Rajdhani und Inter, beide SIL Open Font License 1.1.

## Soundeffekte

Keine fremden Dateien. Alle Effekte erzeugt das Spiel selbst per Synthese (`src/audio/synth.gd`).
