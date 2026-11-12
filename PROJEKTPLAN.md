# Projektplan: FRONTLINE (Arbeitstitel)

Eigenständiges Android-Actionspiel im Genre „Gate-Runner-Shooter“, inspiriert von *Guns Guns Guns* (CHEPERGame, Poki).

Stand: 11.11.2026 · Status: Planung, keine Implementierung begonnen.

---

## 0. Annahmen und offene Entscheidungen

### Annahmen (bitte widersprechen, falls falsch)

| # | Annahme | Auswirkung, falls falsch |
|---|---------|--------------------------|
| A1 | Ein Entwickler, Teilzeit (ca. 10–15 h/Woche), KI-gestützte Entwicklung | Roadmap skaliert linear mit verfügbarer Zeit |
| A2 | Kein Budget für individuell beauftragte 3D-Modelle; Grundlage sind CC0-Assets, eigene modulare Bauteile und Shader | Bei Budget: höherwertige Waffenmodelle möglich |
| A3 | Hochformat (Portrait), Einhandbedienung | Querformat würde Leveldesign und UI komplett ändern |
| A4 | Version 1.0 ohne Echtgeld-Käufe und ohne Werbung | Monetarisierung müsste in die Wirtschaft eingeplant werden |
| A5 | Vertrieb als signierte APK über GitHub Releases, mit Aktualisierung aus der App heraus (siehe 13.5 und 13.6). Play Store höchstens später | Play Store verlangt AAB, Datenschutzerklärung, Altersfreigabe und verbietet die eigene Aktualisierungsfunktion |
| A6 | Gegner sind Drohnen, Roboter und „Glitch“-Wesen, keine Menschen, kein Blut | Niedrige Altersfreigabe, weniger Store-Risiko |
| A7 | Vollständig offline spielbar, kein eigener Server. Einzige Netzwerknutzung ist die Versionsabfrage und der APK-Download bei GitHub | Tägliche Herausforderungen werden lokal aus dem Datum erzeugt |
| A8 | Das GitHub-Repository ist öffentlich | Bei privatem Repository funktioniert die Aktualisierung aus der App nicht ohne eingebautes Zugangstoken, und das wäre ein Sicherheitsfehler |

### Offene Entscheidungen

| # | Frage | Empfehlung |
|---|-------|------------|
| O1 | Endgültiger Name | „Frontline Forge“ (siehe Abschnitt 10), Markenrecherche vor Veröffentlichung nötig |
| O2 | Monetarisierung nach 1.0 | Nur Kosmetik oder freiwillige Belohnungswerbung, niemals Spielstärke |
| O3 | Play-Store-Veröffentlichung | Erst nach geschlossener Beta entscheiden |
| O4 | Budget für Musik und Soundeffekte | Entschieden: kein Budget, nur kostenlose Quellen, siehe 11.4 |
| O5 | Sprachen zum Start | Deutsch und Englisch |
| O6 | Lizenz des öffentlichen Repositorys | Ohne Lizenzdatei gilt „alle Rechte vorbehalten“: Code ist lesbar, aber nicht frei nutzbar. Das ist der sichere Startwert. Offene Lizenz (zum Beispiel MIT) nur bei bewusster Entscheidung |
| O7 | GitHub-Benutzername und Repository-Name | Wird für die Aktualisierungsadresse in der App gebraucht |

### Einschränkung der Referenzanalyse

Die Poki-Seite wurde gelesen (Beschreibung, Steuerung, Genre-Einordnung). Das Spiel selbst wurde nicht gespielt, weil es hinter Einwilligungsdialog und Werbung liegt. Die Mechanik-Analyse stützt sich auf die offizielle Beschreibung und auf die bekannten Konventionen des Genres. Empfehlung: vor Meilenstein M1 eine halbe Stunde selbst spielen und Abschnitt 2 gegenprüfen.

---

## 1. Zusammenfassung der Spielidee

Der Spieler steuert eine Waffenplattform, die automatisch eine Bahn entlangfährt und automatisch feuert. Er lenkt nur nach links und rechts. Auf der Bahn stehen Tore, die die Waffe verändern, Hindernisse, Gegnerwellen und am Ende ein Boss. Zwischen den Läufen baut er dauerhaft ein Arsenal auf: Waffen sammeln, aus Bauteilen schmieden, verbessern, mit Skins versehen.

Der Kern in einem Satz: **„Jeder Lauf ist ein kleiner Waffenbau-Rausch, jedes Menü danach macht den nächsten Lauf interessanter.“**

Zwei große Modi:

- **Kampagne:** handgebaute Level in mehreren Welten mit Bossen und Sonderzielen.
- **Endlos („Tiefenlauf“):** prozedural zusammengesetzte Sektoren mit Build-Auswahl, Mutatoren, Zwischenbossen und prozedural erzeugten Waffenfunden.

---

## 2. Analyse der Referenz

### Was die Referenz ist

Laut Poki ein „Zahlenspiel“ innerhalb der Kategorien Ballerspiele und Laufspiele: links/rechts bewegen, schießen, „die richtigen Wege wählen, um das Einkommen zu steigern“, Monster am Levelende besiegen, Waffen zwischen den Runden verbessern.

### Zentrale Mechaniken

| Mechanik | Funktion | Warum sie wirkt |
|----------|----------|-----------------|
| Automatischer Vorwärtslauf, nur seitliches Lenken | Minimale Eingabe | Sofort verständlich, einhändig spielbar |
| Wege und Tore mit Zahlenwerten | Mikro-Entscheidungen im Sekundentakt | Ständig kleine Erfolgserlebnisse, sichtbares Wachstum |
| Feuerkraft wächst sichtbar im Lauf | Machtfantasie | „Zahlen gehen hoch“ ist unmittelbar befriedigend |
| Endgegner als Abschlussprüfung | Misst den aufgebauten Build | Klarer Spannungsbogen pro Level |
| Geld → dauerhafte Upgrades | Meta-Schleife | Grund für „noch eine Runde“ |

### Schwächen des Genres, die wir gezielt angehen

1. **Scheinentscheidungen:** Meist ist ein Tor offensichtlich besser. → Tore bieten bei uns Verhaltensänderungen und Zielkonflikte, nicht nur größere Zahlen.
2. **Flache Waffen:** Waffen unterscheiden sich nur in Werten. → Waffen bestehen aus Verhaltensbausteinen (Schussmuster, Projektiltyp, Treffereffekt).
3. **Schnelle Sättigung:** Nach einer Stunde ist alles gesehen. → Tiefengestaffelte Inhalte, modulare Waffenerzeugung, Meisterschaften.
4. **Wiederholte Level:** Dieselben Abschnitte in anderer Reihenfolge. → Kampagne handgebaut mit Sonderregeln, Endlos mit Regisseur-System und Mutatoren.
5. **Werbe-Zwang:** → entfällt (A4).

---

## 3. Eigenständiges Konzept und Alleinstellungsmerkmale

### Szenario

Die „Frontline“ ist ein holografisches Waffen-Testgelände. Der Spieler ist Testpilot einer Schmiede, die Prototypen gegen Drohnenschwärme und Systemfehler („Glitches“) erprobt. Das Szenario rechtfertigt realistische, futuristische und völlig absurde Waffen nebeneinander, erklärt die Tore (Kalibrierfelder) und vermeidet Gewalt gegen Menschen.

### Alleinstellungsmerkmale

1. **Schmiede mit vier Bauteil-Slots:** Jede Waffe ist Gehäuse + Lauf + Kern + Mod-Chip. Bauteile bestimmen Verhalten, nicht nur Werte. Daraus entstehen tausende spielerisch verschiedene Kombinationen.
2. **Tore als Build-Entscheidung:** Neben Werttoren gibt es Verhaltenstore (Abpraller, Durchschlag, Teilung, Element) und Risikotore (starker Bonus mit Nachteil).
3. **Synergien:** Bestimmte Kombinationen lösen benannte Effekte aus (zum Beispiel Eis + Durchschlag = „Splitterlanze“). Entdeckte Synergien landen im Kodex.
4. **Tiefenlauf mit Sicherungspunkten:** Funde im Endlos-Modus gehören erst nach dem nächsten Sicherungspunkt dauerhaft dem Spieler. Wer weiterläuft, riskiert nichts bereits Gesichertes, aber den ungesicherten Fund.
5. **Tiefengestaffelte Inhalte:** Manche Kerne, Mutatoren, Gegner und Anomalien existieren erst ab Sektor 30, 50, 75, 100. Lange Läufe zeigen wirklich Neues.
6. **Aufwertbare Lieblingswaffe:** Jede Waffe kann in der Seltenheit aufsteigen. Eine früh gefundene Waffe wird nie wertlos.
7. **Kodex:** Sammlung aller entdeckten Bauteile, Synergien, Gegner und Anomalien mit Fortschrittsbelohnungen.

---

## 4. Game-Design-Dokument

### 4.1 Kernschleife

```
Lauf starten → lenken, Tore wählen, Gegner zerstören → Boss
   → Ergebnis: Münzen, XP, Bauteile, evtl. Waffe
   → Schmiede/Arsenal: verbessern, umbauen, ausrüsten
   → nächster Lauf (stärker oder mit neuem Build)
```

Zeitrahmen: Kampagnenlevel 60–120 Sekunden. Tiefenlauf 5–30 Minuten, jederzeit pausierbar und an Sicherungspunkten unterbrechbar (Fortsetzen nach App-Neustart).

### 4.2 Steuerung

- **Standard:** Finger irgendwo auf den Bildschirm legen und ziehen, die Plattform folgt relativ zur Fingerbewegung. Feuer automatisch.
- **Fähigkeit:** Eine aktive Spezialfähigkeit der Waffe mit Abklingzeit, Auslösung per Knopf (Position wählbar) oder Doppeltipp.
- **Alternativen:** Zwei Richtungstasten, Gamepad, Tastatur (für Tests und Chromebooks).
- Kein manuelles Zielen. Tiefe entsteht durch Position, Torwahl und Fähigkeits-Timing.

### 4.3 Elemente auf der Bahn

| Element | Beschreibung |
|---------|--------------|
| Werttor | Verändert einen Wert: Schaden, Feuerrate, Projektilanzahl, Reichweite. Additiv oder multiplikativ |
| Verhaltenstor | Fügt eine Eigenschaft hinzu: Abpraller, Durchschlag, Teilung, Zielsuche, Element |
| Risikotor | Starker Bonus plus Nachteil, zum Beispiel doppelter Schaden bei halber Reichweite |
| Schießbares Tor | Wert steigt, solange man darauf schießt. Kostet Zeit, die an anderer Stelle fehlt |
| Hindernis | Blöcke mit Lebenspunkten, bewegliche Barrieren, Laserschranken |
| Gegner | Kommen entgegen oder halten Position, siehe 4.4 |
| Münzkapsel / Bauteilkiste | Belohnungen, oft hinter Hindernissen oder auf der riskanteren Seite |
| Boss | Am Levelende, mit Phasen und Schwachstellen |

**Lebenssystem:** Die Plattform hat Schildpunkte. Kontakt mit Gegnern oder Hindernissen kostet Schild. Schild null bedeutet Laufende (Kampagne: Neustart des Levels, Tiefenlauf: Auszahlung des Gesicherten).

### 4.4 Gegnerfamilien

| Familie | Verhalten | Gegenmittel |
|---------|-----------|-------------|
| Schwarm | Viele schwache Drohnen | Flächenschaden, Streuung |
| Panzer | Langsam, viel Leben, Frontpanzerung | Durchschlag, hoher Einzelschaden |
| Springer | Wechselt die Spur | Zielsuche, breite Muster |
| Schildträger | Schützt andere Gegner | Abpraller, Flankieren, Blitzketten |
| Schütze | Feuert langsame Projektile, denen man ausweicht | Reichweite, Priorisierung |
| Teiler | Zerfällt beim Tod in kleinere | Flächenschaden |
| Glitch | Teleportiert, kurz unverwundbar | Dauerfeuer, Timing |
| Elite | Beliebige Familie mit einem Zusatzmerkmal (schnell, explosiv, regenerierend) | abhängig vom Merkmal |

Jede Familie ist eine Datendefinition plus ein Verhaltensskript. Neue Gegner entstehen überwiegend durch neue Datensätze.

### 4.5 Bosse

Jede Welt hat einen Boss mit zwei bis drei Phasen und klar lesbaren Angriffsmustern (Ankündigung durch Bodenmarkierung und Ton). Bosse geben beim ersten Sieg ein garantiertes einzigartiges Bauteil, danach eine Chance auf seltene Bauteile.

---

## 5. Spielmodi

### 5.1 Kampagne

- **Umfang 1.0:** 5 Welten × 20 Level = 100 Level. MVP: 1 Welt × 15 Level.
- **Welten:** Trainingsraster (Neon-Gitter), Schrottwüste, Kryo-Anlage, Orbitalwerft, Glitch-Kern. Jede Welt führt zwei Gegnerfamilien, ein Hindernis und eine Regelbesonderheit ein.
- **Levelstruktur:** Jedes 5. Level ist ein Sonderlevel, jedes 20. ein Bosslevel.
- **Sonderlevel-Typen:** Zeitrennen, „Nur eine Waffe“-Vorgabe, Münzrausch, Überleben ohne Tore, Eskorte eines Frachtmoduls.
- **Sterne:** Bis zu drei pro Level: abgeschlossen, ohne Schildverlust, Levelziel erfüllt (zum Beispiel alle Kisten gesammelt). Sterne schalten Welten und Schmiede-Funktionen frei.
- **Zielklarheit:** Die Levelkarte zeigt immer das nächste Freischaltziel („Noch 4 Sterne bis Kryo-Anlage“, „Level 18: neues Gehäuse“).
- **Levelbau:** Level bestehen aus handgebauten Abschnitten (Segmenten) von 10–20 Metern, die in einer Leveldatei gereiht werden. Das hält den Bauaufwand pro Level bei etwa 30–60 Minuten.

### 5.2 Tiefenlauf (Endlos)

**Struktur:** Der Lauf besteht aus Sektoren von etwa 45 Sekunden. Nach jedem Sektor folgt eine Auswahl aus drei Karten (Verbesserung, Verhaltensänderung oder Risikopakt). Alle 5 Sektoren ein Zwischenboss mit Sicherungspunkt. Alle 10 Sektoren wechselt das Biom und ein dauerhafter Mutator kommt hinzu.

**Gegen Wiederholung wirken sechs Systeme zusammen:**

1. **Regisseur:** Stellt Sektoren aus Segmenten zusammen. Er hat ein Bedrohungsbudget, das mit der Tiefe steigt, und kauft davon Gegnergruppen. Er vermeidet Wiederholungen der letzten Segmente und wechselt gezielt zwischen Anspannung und Erholung.
2. **Mutatoren:** Regeländerungen wie „Gegner explodieren“, „Tore bewegen sich“, „Nebel“, „Doppelte Geschwindigkeit, doppelte Münzen“. Start-Pool etwa 15, Ziel 40.
3. **Ereignisse:** Zufällige Zwischenspiele: Händlerdrohne, Tresorraum, Elitejagd, Glitch-Riss mit verdrehten Regeln, Schmiedekammer (Bauteil im Lauf tauschen).
4. **Kartenauswahl:** Etwa 80 Karten mit Seltenheiten und Synergien. Der Build unterscheidet sich von Lauf zu Lauf.
5. **Tiefenstaffelung:** Inhalts-Pools haben eine Mindesttiefe. Beispiele: Plasma-Kerne ab Sektor 20, Gegnerfamilie „Glitch“ ab 30, Anomalie „Spiegelbahn“ ab 50, mythische Fundchance ab 75.
6. **Prozedurale Waffenfunde:** Siehe Abschnitt 7.4. Die Fundqualität steigt mit der Tiefe ohne Obergrenze der Kombinationen.

**Skalierung:** Siehe Abschnitt 14.4. Kurz: Gegnerwerte wachsen exponentiell, die Spielerstärke im Lauf wächst über Karten ebenfalls multiplikativ. Ab einem bestimmten Punkt gewinnt die Gegnerkurve, sodass jeder Lauf endet, aber ein besseres Arsenal diesen Punkt verschiebt.

**Belohnungen:** Münzen und XP pro Sektor, Bauteile bei Bossen, Meilensteinbelohnungen bei erstmaligem Erreichen von Sektor 10, 20, 30 und so weiter (einmalig, hochwertig). Bestenliste lokal: tiefster Sektor, höchster Schaden, schnellster Sektor 25.

**Sicherungspunkt-Regel:** Münzen und XP sind immer sicher. Waffen- und Bauteilfunde gelten als „ungesichert“ bis zum nächsten Zwischenboss. Scheitert der Spieler vorher, wird jeder ungesicherte Fund zu Schrott (Handwerksmaterial) umgewandelt. Das erzeugt Spannung ohne Frust, weil nie etwas verloren geht, das man schon besaß.

**Tageslauf (ab 1.0):** Ein Tiefenlauf mit festem Startwert aus dem Datum, gleicher Sektorfolge für alle, eigene Bestenliste. Kein Server nötig.

---

## 6. Progression und Wirtschaft

### 6.1 Währungen (bewusst wenige)

| Währung | Quelle | Verwendung |
|---------|--------|------------|
| Münzen | Jeder Lauf, Levelbelohnungen, Erfolge | Waffen-Upgrades, Shop, Schmieden |
| Schrott | Zerlegen von Waffen und Bauteilen, ungesicherte Funde | Schmieden, Seltenheitsaufstieg |
| Prismen | Erfolge, Meisterschaft, Meilensteine, Spieler-Level | Ausschließlich Skins und Kosmetik |

Drei Währungen mit klar getrennten Zwecken. Prismen können nie Spielstärke kaufen.

### 6.2 Spieler-Level und XP

- XP aus allem: Gegner, Levelabschluss, Sektoren, Herausforderungen.
- Formel: `XP_bis_nächstes_Level(n) = 100 × n^1,5` (gerundet). Level 10 braucht etwa 3.200 XP, Level 50 etwa 35.400 XP.
- Ziel: Level 1–10 in den ersten 90 Minuten, danach etwa ein Level je 30–45 Minuten Spielzeit.
- Jedes Level gibt eine Belohnung. Jedes 5. Level eine Funktions- oder Inhaltsfreischaltung.

| Level | Freischaltung |
|-------|---------------|
| 2 | Arsenal und Upgrades |
| 4 | Schmiede (Bauteile tauschen) |
| 6 | Tiefenlauf |
| 8 | Tägliche Herausforderungen |
| 10 | Dritter Ausrüstungsplatz (Fähigkeitsmodul) |
| 15 | Seltenheitsaufstieg |
| 20 | Wochenlauf, Mutator-Wahl für eigene Läufe |
| 25+ | Abwechselnd Bauteil-Baupläne, Skins, Prismen |

### 6.3 Einnahmen und Ausgaben (Zielwerte)

- Kampagnenlevel: `Münzen ≈ 80 × (1 + 0,06 × Levelnummer)` plus Sternbonus.
- Tiefenlauf: `Münzen pro Sektor ≈ 60 × 1,05^Sektor`.
- Upgrade-Kosten pro Stufe: `Basis × 1,15^Stufe`, Basis abhängig vom Wert (Schaden 50, Feuerrate 60, Spezial 100).
- Zielrhythmus: Nach jedem Lauf mindestens ein bezahlbares Upgrade in den ersten 5 Stunden. Danach ein Upgrade alle 2–3 Läufe, ergänzt durch Bauteilfunde, damit kein Lauf „leer“ endet.
- Keine Energie, keine Wartezeiten, keine Timer auf Freischaltungen.

### 6.4 Schutz vor Grind

- **Aufhol-Regel:** Upgrades für Waffen mit niedriger Stufe kosten weniger, je höher die höchste eigene Waffenstufe ist. Das fördert Experimente.
- **Rückerstattung:** Zerlegen gibt 70 % der investierten Münzen und den Schrottwert zurück.
- **Pech-Schutz:** Garantierte seltene Bauteile nach einer festen Zahl von Kisten ohne Treffer (siehe 14.6).

---

## 7. Waffen, Upgrades, Raritäten, Skins

### 7.1 Modularer Aufbau

Jede Waffe besteht aus vier Bauteilen:

| Slot | Bestimmt | Beispiele |
|------|----------|-----------|
| **Gehäuse** | Familie, Grundwerte, aktive Fähigkeit, Modell-Basis | Pistole, MP, Sturmgewehr, MG, Schrotflinte, Präzisionsgewehr, Werfer, Strahler, Experimentalrahmen |
| **Lauf** | Schussmuster | Einzel, Salve, Fächer, Doppelspirale, Welle, Dauerstrahl, Bogenwurf, Schwarmrakete, Sperrfeuer |
| **Kern** | Projektiltyp und Element | Kinetik, Brand, Kryo, Schock, Säure, Plasma, Laser, Gravitation, Leere, Glitch |
| **Mod-Chip** | Zusatzregeln (Affixe) | Abpraller, Durchschlag, Teilung beim Treffer, Zielsuche, Lebensraub auf Schild, Kettenblitz, Wachsende Projektile |

Rechenbeispiel für den Zielumfang 1.0: 40 Gehäuse × 15 Läufe × 12 Kerne × 60 Chips = 432.000 Kombinationen, bevor Affix-Werte und einzigartige Merkmale dazukommen.

**Unterscheidbarkeitsregel:** Zwei Waffen gelten nur dann als verschieden, wenn sie sich in mindestens einer Verhaltensachse unterscheiden (Muster, Projektiltyp, Treffereffekt oder Fähigkeit). Der Generator bietet dem Spieler keine Waffe an, die sich von einer bereits besessenen nur in Zahlen unterscheidet. Solche Funde werden als Upgrade-Material ausgegeben.

**Elemente mit Funktion:**

| Element | Effekt |
|---------|--------|
| Brand | Schaden über Zeit, greift auf Nachbarn über |
| Kryo | Verlangsamt, gefrorene Gegner zersplittern bei hohem Einzelschaden |
| Schock | Springt auf nahe Gegner, stark gegen Schilde |
| Säure | Senkt Panzerung |
| Gravitation | Zieht Gegner zusammen |
| Leere | Durchdringt Schilde, geringerer Grundschaden |

### 7.2 Raritäten

Seltenheit erhöht vor allem die **Zahl der Eigenschaften**, nur wenig die Grundwerte. So bleibt eine gewöhnliche Waffe brauchbar und eine mythische interessant statt nur stärker.

| Seltenheit | Wertbudget | Affix-Plätze | Besonderheit |
|------------|-----------|--------------|--------------|
| Common | 100 % | 0 | – |
| Uncommon | 106 % | 1 | – |
| Rare | 112 % | 2 | – |
| Epic | 118 % | 3 | Verbesserte Fähigkeit |
| Legendary | 124 % | 3 | Ein einzigartiges Merkmal, eigener Schusseffekt |
| Mythic | 130 % | 4 | Einzigartiges Merkmal plus Signaturverhalten, das die Spielweise ändert |

Beispiele für einzigartige Merkmale: „Jeder zehnte Schuss ist ein Abbild des Bosses, den du zuletzt besiegt hast“, „Projektile kehren zurück“, „Feuerrate steigt, solange du dich nicht bewegst“.

### 7.3 Wege zu neuen Waffen

| Weg | Was man bekommt |
|-----|-----------------|
| Kampagnenfortschritt | Feste Gehäuse und Läufe an definierten Leveln |
| Bosse | Garantiertes einzigartiges Bauteil beim ersten Sieg |
| Spieler-Level | Baupläne |
| Shop (Münzen) | Rotierendes Angebot aus bereits entdeckten Bauteiltypen, niedrige bis mittlere Seltenheit |
| Tiefenlauf-Funde | Prozedurale Waffen, Qualität nach Tiefe |
| Meilensteine | Einmalige Sonderbauteile |
| Schmiede | Eigene Kombination aus besessenen Bauteilen |
| Herausforderungen und Meisterschaft | Chips und Skins |

### 7.4 Prozeduraler Waffengenerator

Eingaben: Startwert, Tiefe beziehungsweise Quellstufe, Seltenheit, Liste der freigeschalteten Bauteiltypen.

Ablauf:

1. Seltenheit würfeln (Tabelle 14.6, Tiefe verschiebt die Gewichte).
2. Gehäuse, Lauf, Kern aus gewichteten Pools ziehen. Verbotene Paare stehen in einer Ausschlussliste (zum Beispiel Dauerstrahl + Bogenwurf).
3. Affixe ziehen, keine doppelten, keine widersprüchlichen.
4. Werte aus dem Wertbudget verteilen (siehe 14.1).
5. Unterscheidbarkeitsregel gegen das Inventar prüfen.
6. Namen aus Bausteinen erzeugen („Kryo-Fächer ‚Wintersturm‘ Mk III“).
7. Modell aus Gehäuse-Mesh plus Lauf-Aufsatz plus Kern-Leuchtfarbe zusammensetzen.

Eine Waffe wird nur als Startwert plus Bauteil-IDs plus Stufen gespeichert. Das hält Speicherstände klein und macht jede Waffe reproduzierbar.

### 7.5 Upgrades

- **Wertstufen:** Schaden, Feuerrate, Präzision, Magazin beziehungsweise Hitzekapazität, Projektilgeschwindigkeit, kritische Treffer, Elementstärke. Je 20 Stufen, steigende Kosten, abnehmender Zuwachs.
- **Fähigkeitsstufen:** 5 Stufen, jede dritte Stufe ändert das Verhalten (zum Beispiel Granate → Streugranate).
- **Seltenheitsaufstieg:** Kostet Schrott und ein Duplikat-Bauteil. Öffnet einen Affix-Platz.
- **Affix-Neuwurf:** Ein Affix gegen Schrott neu würfeln, Auswahl aus drei Optionen statt reinem Zufall.
- **Aufsätze:** Fallen bewusst mit dem Mod-Chip-Slot zusammen. Ein weiteres Aufsatz-System wäre doppelte Komplexität ohne Mehrwert.

### 7.6 Balance-Leitplanken

- Gleiches Wertbudget je Seltenheit für alle Waffen, nur anders verteilt.
- Jede Waffenfamilie hat eine klare Schwäche (Schrotflinte: Reichweite, Präzisionsgewehr: Schwärme).
- Gegnerfamilien belohnen unterschiedliche Familien, daher lohnt sich mehr als eine Waffe.
- Kampagnen-Sonderlevel und Wochenläufe schreiben Familien oder Elemente vor.
- Nutzungsstatistik im Entwicklermenü zeigt dominante Kombinationen.

### 7.7 Skins und Kosmetik

**Technik:** Ein Skin ist ein Datensatz mit Shader-Parametern: Farbpalette, Mustertextur, Metallanteil, Leuchtstärke, Animation (Laufrichtung, Puls), Mündungsfeuer-Farbe, Projektilspur, Treffereffekt. Dadurch passt jeder Skin auf jede Waffe, und neue Skins kosten Minuten statt Tage.

**Kategorien:** Neon, Gold, Chrom, Feuer, Eis, Hologramm, Carbon, Glitch, Kosmos, animierte Sonderserien, Welt-Serien (je Welt ein Set), Meisterschafts-Skins je Waffenfamilie.

**Weitere Kosmetik:** Plattform-Skins, Projektilspuren, Abschuss-Effekte, Profilbanner, Titel.

**Inventar:** Raster mit Filter (Familie, Seltenheit, Element, Favoriten), Sortierung, 3D-Vorschau mit Drehen und Probeschuss, Vergleichsansicht, Ausrüstungssets.

Skins haben keinerlei Einfluss auf Werte.

---

## 8. Langfristige Motivation

| System | Inhalt | Belohnung |
|--------|--------|-----------|
| Erfolge | Etwa 80, in Stufen (Bronze bis Platin) | Prismen, Titel |
| Waffen-Meisterschaft | Je Familie 10 Ränge durch Nutzung | Skins, familienspezifische Chips |
| Kodex | Bauteile, Synergien, Gegner, Mutatoren, Anomalien | Prismen je Seite, Abschlussbelohnung je Kapitel |
| Missionsreihen | Mehrteilige Aufgaben mit kleiner Geschichte („Protokoll Winter“: Kryo-Waffen meistern) | Einzigartige Bauteile |
| Tägliche Aufträge | 3 pro Tag, einer davon frei austauschbar | Münzen, Schrott |
| Wochenlauf | Tiefenlauf mit Sonderregeln | Prismen, Wochen-Skin |
| Tiefen-Meilensteine | Sektor 10, 20, … 200 | Einmalige Bauteile, Banner |
| Bestleistungen | Tiefe, Schaden, Zeit, je Waffenfamilie | Vergleich mit sich selbst |
| Prestige „Neukalibrierung“ (nach 1.0) | Kampagne mit Mutatoren neu spielen | Exklusive Kosmetik, höheres Stufenlimit |

**Grundsätze gegen Verpflichtungsdruck:**

- Tägliche Aufträge sammeln sich bis zu drei Tage an. Kein Serienzähler, der verfällt.
- Keine zeitlich begrenzten Inhalte, die für immer verschwinden. Wochen-Skins kehren im Shop zurück.
- Aufträge werden durch normales Spielen erfüllt, nicht durch ungeliebte Sonderwege.

**Zusätzliche Ideen:**

- **Schießstand:** Freies Testen jeder Kombination gegen wählbare Gegner, mit Schadensanzeige.
- **Build-Codes:** Eine Waffe als kurzer Textcode zum Teilen. Der Empfänger kann sie nachbauen, sobald er die Bauteile besitzt. Funktioniert ohne Server.
- **Geisterlauf:** Eigener bester Tageslauf als Schattenspur.

---

## 9. UI und UX

### 9.1 Menüstruktur

```
Start (Logo, Laden)
└─ Hauptmenü  [Spielen | Arsenal | Schmiede | Shop | Profil]   (untere Leiste)
   ├─ Spielen
   │  ├─ Kampagne → Weltkarte → Levelauswahl → Levelvorschau (Ziele, Ausrüstung) → Lauf
   │  ├─ Tiefenlauf → Vorbereitung (Ausrüstung, Mutator-Wahl) → Lauf
   │  ├─ Tages-/Wochenlauf
   │  └─ Schießstand
   ├─ Arsenal
   │  ├─ Waffenliste → Waffendetail → Upgrades | Skins | Vergleich | Zerlegen
   │  ├─ Skin-Inventar
   │  └─ Ausrüstungssets
   ├─ Schmiede → Bauteile kombinieren | Seltenheitsaufstieg | Affix-Neuwurf
   ├─ Shop → Tagesangebot | Bauteile | Kosmetik
   ├─ Profil
   │  ├─ Spieler-Level und Belohnungspfad
   │  ├─ Erfolge
   │  ├─ Statistiken
   │  ├─ Kodex
   │  └─ Aufträge und Missionsreihen
   └─ Einstellungen (Zahnrad oben rechts, aus jedem Menü und der Pause erreichbar)

Im Lauf: HUD → Pause (Fortsetzen | Einstellungen | Neustart | Aufgeben)
Nach dem Lauf: Ergebnisseite (Münzen, XP, Funde, Sterne, Auftragsfortschritt)
               → [Nochmal | Weiter | Arsenal]
```

### 9.2 UX-Regeln

- Wichtige Bedienelemente im unteren Bildschirmdrittel (Daumenzone). Mindestgröße 48 dp.
- Vom App-Start bis in einen Lauf höchstens zwei Tipps („Weiterspielen“-Knopf im Hauptmenü).
- Sichere Bereiche für Notch und Gestenleiste werden berücksichtigt.
- Rote Hinweispunkte nur für wirklich Neues, mit „Alle als gesehen markieren“.
- HUD minimal: Schild, Fortschrittsbalken des Levels, Fähigkeitsknopf, Münzen. Schadenszahlen abschaltbar.
- Jede Belohnung zeigt vor dem Lauf, was erreichbar ist, und nach dem Lauf, was fehlte.
- Zurück-Geste von Android funktioniert überall erwartungsgemäß.
- Einführung durch spielbare erste drei Level statt Textfenster.

### 9.3 Designsystem

| Baustein | Festlegung |
|----------|------------|
| Grundfarben | Tiefblau `#0B1020` (Hintergrund), Schiefer `#1A2238` (Flächen) |
| Akzente | Cyan `#22E1FF` (primär, Interaktion), Magenta `#FF3D81` (Gefahr, Gegner), Bernstein `#FFB020` (Münzen, Belohnung) |
| Seltenheitsfarben | Grau, Grün, Blau, Violett, Orange, Rot-Gold-Verlauf. Zusätzlich je Seltenheit eine eigene Rahmenform für Farbenblinde |
| Schrift | Überschriften: Rajdhani (halbfett), Fließtext und Zahlen: Inter. Beide unter Open Font License |
| Formen | Abgeschrägte Ecken (45°), dünne Leuchtkanten, keine Verläufe auf Text |
| Icons | Einheitliche Strichstärke, zweifarbig, als Vektorgrafik |
| Bewegung | Übergänge 150–250 ms, Ein- und Ausblenden mit leichter Verschiebung, vollständig abschaltbar |
| Ton | Jede Interaktion hat einen leisen, kurzen Klang, drei Tonhöhen für Hierarchieebenen |

Das Designsystem wird als ein Godot-Theme umgesetzt, damit Änderungen an einer Stelle alle Menüs treffen.

---

## 10. Name, Logo, Branding

### Namensvorschläge

| Name | Wirkung | Anmerkung |
|------|---------|-----------|
| **Frontline Forge** | Action plus Schmiede, beschreibt das Kernsystem | Empfehlung |
| Barrelstorm | Laut, eingängig | Sehr generisch im Genre |
| Neon Calibre | Stilbetont | Schreibweise uneinheitlich (Caliber/Calibre) |
| Gunforge Run | Selbsterklärend | Wenig eigenständig |
| Arsenal Zero | Geheimnisvoll, kurz | Sagt wenig über das Spiel |
| Voltline | Kurz, modern | Kein Waffenbezug |

Alle Namen müssen vor Veröffentlichung auf Markenrechte und Store-Kollisionen geprüft werden (O1).

### Logo-Konzept „Frontline Forge“

- **Bildmarke:** Zwei nach oben zeigende Winkel (Chevrons), die zusammen ein stilisiertes „F“ und zugleich eine Bahn mit Tor bilden. Zwischen den Winkeln ein kleiner Funke als Schmiede-Hinweis.
- **Farben:** Cyan-Winkel auf Tiefblau, Funke in Bernstein.
- **App-Icon:** Nur die Bildmarke, formatfüllend, ohne Text. Funktioniert einfarbig (Android-Themensymbole) und in 48 px.
- **Wortmarke:** „FRONTLINE“ in breiter, kantiger Schrift, „FORGE“ darunter gesperrt und dünner.
- **Abgrenzung zur Referenz:** Keine Wortwiederholung, keine comichafte Waffe im Logo, kühle Neonpalette statt bunter Cartoon-Optik.

---

## 11. Grafik und Ton

### 11.1 Visueller Stil

Stilisiertes 3D mit klaren Formen und geringer Polygonzahl, getragen von Licht, Leuchtkanten und Effekten statt von Texturdetails. Feste Kamera schräg hinter der Plattform.

Begründung: Dieser Stil sieht mit Shadern und Partikeln hochwertig aus, ist für einen Einzelentwickler herstellbar und läuft auf schwachen Geräten.

Bausteine:

- **Waffen:** Modular aus Gehäuse-, Lauf- und Kernteilen mit Andockpunkten. 300–1.500 Dreiecke je Waffe.
- **Effekte:** Mündungsfeuer, Projektilspuren, Trefferblitze, Auflösung der Gegner in Lichtsplitter, Bildschirmerschütterung, kurze Zeitlupe bei Bossphasen.
- **Umgebung:** Je Welt eigene Farbstimmung, bewegte Hintergrundebenen, Nebel in der Ferne (verdeckt zugleich das Nachladen von Segmenten).
- **Licht:** Ein gerichtetes Licht mit Schatten (abschaltbar), Leuchten über Emission und Glow, keine dynamischen Punktlichter in Masse.
- **Menüs:** 3D-Waffenvorschau auf Drehteller, weiche Übergänge, animierte Belohnungsenthüllung.

### 11.2 Grafikoptionen

| Option | Werte |
|--------|-------|
| Voreinstellung | Niedrig, Mittel, Hoch, Ultra, Benutzerdefiniert. Erststart wählt automatisch nach kurzem Leistungstest |
| Render-Skalierung | 50–100 % |
| Schatten | Aus, Niedrig, Hoch |
| Partikeldichte | 25, 50, 100 % |
| Effektqualität (Glow, Verzerrung) | Aus, Niedrig, Hoch |
| Kantenglättung | Aus, FXAA, MSAA 2× (nur Hoch und Ultra) |
| Bildratenlimit | 30, 60, 90, 120 (nur vom Display unterstützte Werte) |
| Energiesparmodus | 30 Bilder, 70 % Skalierung, reduzierte Partikel, ein Schalter |
| Bildschirmerschütterung | 0–100 % |
| Schadenszahlen | An, Aus |

### 11.3 Tonkonzept

- **Waffen:** Jede Familie hat eine eigene Klangsignatur aus Schichten (Anschlag, Körper, Ausklang). Der Kern färbt den Klang (Kryo: gläsern, Schock: knisternd). Leichte zufällige Tonhöhen- und Lautstärkeabweichung pro Schuss verhindert Ermüdung.
- **Dauerfeuer:** Bei hoher Feuerrate wird auf eine Schleife umgeschaltet statt hunderte Einzelklänge zu stapeln. Stimmenbegrenzung je Kategorie.
- **Treffer:** Unterschiedlich nach Material (Panzer, Schild, Glitch). Kritische Treffer mit hellem Zusatzton.
- **Musik:** Episch, als Hybrid aus Orchester und Elektronik: große Trommeln, tiefe Blechbläser, Streicher-Ostinati und Chor über treibenden Synthesizer-Bässen. Das verbindet das geforderte epische Gefühl mit dem Neon-Stil. Adaptiv in drei Schichten: Grundspur, Kampfschicht, Boss-Schicht. Details in 11.4.
- **Belohnungen:** Aufsteigende Tonfolge, deren Länge mit der Seltenheit wächst.
- **Menü:** Leise, kurz, weich. Nie lauter als das Spiel.
- **Busse:** Master, Musik, Effekte, Waffen, Umgebung, Menü, jeweils getrennt regelbar. Automatisches Absenken der Musik bei Bossansagen.

### 11.4 Musik und Soundeffekte: Umfang, Qualität, Beschaffung

**Musikstücke (Zielumfang 1.0, etwa 12 Stücke):**

| Stück | Charakter |
|-------|-----------|
| Hauptthema (Menü) | Wiedererkennbare Melodie, ruhig beginnend, heroisch. Das Motiv kehrt in allen anderen Stücken wieder |
| Je Welt ein Thema (5) | Gleiches Grundmotiv, eigene Klangfarbe: Trainingsraster elektronisch, Schrottwüste perkussiv und rau, Kryo-Anlage gläsern und weit, Orbitalwerft orchestral und groß, Glitch-Kern verzerrt und bedrohlich |
| Bossthema (2 Varianten) | Volles Orchester mit Chor, schnelleres Tempo, Steigerung je Bossphase |
| Tiefenlauf (2) | Lange Schleifen, deren Intensität mit der Tiefe wächst (zusätzliche Schichten ab Sektor 10, 25, 50) |
| Sieg und Niederlage | Kurze Fanfaren, 5–10 Sekunden |
| Schmiede/Arsenal | Ruhige Variante des Hauptthemas |

MVP: Hauptthema, ein Weltthema, ein Bossthema, ein Tiefenlauf-Stück, Fanfaren.

**Soundeffekte (Zielumfang 1.0, etwa 250–300 Klänge):**

- Waffen: je Gehäusefamilie 3–5 Schussvarianten, je Kern eine Klangschicht, Fähigkeiten, Nachladen beziehungsweise Überhitzen.
- Treffer: je Material 3 Varianten, kritischer Treffer, Schildbruch.
- Gegner: Erscheinen, Angriffsankündigung, Zerstörung je Familie. Bosse mit eigenen Klängen je Phase.
- Explosionen: klein, mittel, groß, je 3 Varianten, mit tiefem Bassanteil und passender Vibration.
- Tore: je Tortyp ein Klang, steigende Tonhöhe bei mehreren positiven Toren in Folge.
- Belohnungen: Münzen (Tonhöhe steigt bei Serie), Kiste öffnen, Enthüllung je Seltenheit, Levelaufstieg, Erfolg.
- Menü und Umgebung: Tippen, Wechsel, Bestätigen, Fehler, Kaufen, Upgrade. Je Welt eine Umgebungsschleife.

**Qualitätsregeln:**

- Jeder häufige Klang hat mindestens drei Varianten plus zufällige Tonhöhenabweichung.
- Einheitliche Lautheit je Kategorie, Begrenzer auf dem Master-Bus, damit Dauerfeuer nie übersteuert.
- Waffen dürfen die Musik nicht zudecken: Frequenzbereiche werden aufgeteilt (Musik-Bass weicht bei Explosionen kurz zurück).
- Prüfung auf Handylautsprecher und Kopfhörer. Tiefe Bässe sind auf Handylautsprechern unhörbar, daher braucht jeder wichtige Klang auch Mittenanteil.
- Ermüdungstest: 30 Minuten Dauerlauf, danach darf kein Klang als störend auffallen.

**Beschaffung (ersetzt O4):**

| Weg | Qualität | Kosten | Einschätzung |
|-----|----------|--------|--------------|
| Freie Bibliotheken (CC0/CC-BY, zum Beispiel Freesound, OpenGameArt, Kenney) | Schwankend, Musik uneinheitlich | Keine | Für Prototyp und viele Soundeffekte geeignet |
| Gekaufte Pakete (Musik- und Effektpakete für Spiele) | Hoch und einheitlich | Etwa 30–150 € gesamt | Empfehlung für 1.0: ein zusammengehöriges Epik-Musikpaket und ein Sci-Fi-Waffenpaket |
| KI-erzeugte Musik | Mittel bis hoch | Abo | Möglich, aber Nutzungsrechte je Anbieter prüfen, adaptive Schichten schwer umsetzbar |
| Auftragskomposition | Sehr hoch, exakt passend, adaptive Schichten möglich | Etwa 100–400 € je Minute | Nur bei Budget, dann zuerst Hauptthema und Bossthema |
| Eigene Effekte (Synthese, Aufnahme, Schichtung in Audacity) | Hoch bei Sorgfalt | Zeit | Für Signaturklänge der Waffen sinnvoll |

**Entscheidung (11.11.2026): ausschließlich kostenlose Quellen.** Die übrigen Wege der Tabelle bleiben nur zur Einordnung stehen.

Vorgehen, damit das Ergebnis trotzdem einheitlich klingt:

- **Musik aus möglichst wenigen Händen:** Stücke von ein bis zwei Komponisten wählen statt von zwölf verschiedenen. Zuerst das Hauptthema festlegen, alle weiteren Stücke danach auswählen (gleiche Besetzung, ähnliches Tempo, ähnliche Abmischung).
- **Lizenzen:** Bevorzugt CC0. CC-BY ist erlaubt, verlangt aber Namensnennung im Info-Bildschirm. Nicht verwendbar: Lizenzen mit „NC“ (nicht kommerziell), „ND“ (keine Bearbeitung) und „SA“ (Weitergabe unter gleichen Bedingungen). Lizenz jeder Datei vor dem Einbau auf der Quellseite prüfen.
- **Angleichen:** Alle Musikstücke auf gleiche Lautheit bringen, Schleifenpunkte in Audacity sauber schneiden.
- **Adaptive Schichten vereinfacht:** Fertige Stücke liegen nicht in Einzelspuren vor. Ersatz: je Situation ein eigenes Stück mit weicher Überblendung (Erkundung → Kampf → Boss) plus ein Tiefpassfilter in ruhigen Momenten. Echte Schichten nur dort, wo eine Quelle Einzelspuren anbietet.
- **Soundeffekte:** Grundlage aus CC0-Paketen. Signaturklänge der Waffen durch Schichten mehrerer freier Klänge selbst bauen, das gleicht Qualitätsunterschiede aus.
- **Zeitaufwand statt Geld:** Für Suche, Auswahl, Schnitt und Angleichen etwa 6–8 Personentage zusätzlich in M4/M5 einplanen.

Verbleibendes Risiko: Wirklich epische Orchestermusik ist unter freien Lizenzen seltener als elektronische. Falls die Suche nicht genug passende Stücke ergibt, verschiebt sich die Mischung in Richtung Elektronik mit orchestralen Akzenten.

Jede Tondatei wird mit Quelle und Lizenz in `docs/lizenzen.md` eingetragen.

---

## 12. Einstellungen und Barrierefreiheit

### Kategorien

**Grafik:** siehe 11.2.

**Audio:** Gesamt, Musik, Effekte, Waffen, Umgebung, Menü, Vibration (Stärke und getrennt für Treffer, Schaden, Menü), Mono-Ausgabe.

**Steuerung:** Modus (Ziehen, Tasten, Gamepad), Empfindlichkeit, Linkshänder-Layout (spiegelt Fähigkeits- und Pauseknopf), Position und Größe des Fähigkeitsknopfs frei verschiebbar, Doppeltipp für Fähigkeit an/aus, Tastenbelegung für Gamepad und Tastatur, Touch-Feedback.

**Barrierefreiheit:**

| Option | Umsetzung |
|--------|-----------|
| Farbenblind-Modi | Drei Paletten plus freie Wahl der Gegner-, Tor- und Gefahrenfarbe. Wichtige Informationen nie nur über Farbe (Form und Symbol zusätzlich) |
| Hoher Kontrast | Dunklerer Hintergrund, Umrisse um Gegner und Tore |
| Schriftgröße | 85, 100, 115, 130 %. Alle Layouts mit flexiblen Containern |
| Reduzierte Bewegung | Keine Erschütterung, keine Zooms, schlichte Übergänge |
| Reduzierte Effekte | Kein Blitzen, gedämpfter Glow, Partikelobergrenze |
| Untertitel | Für Ansagen und Bosshinweise |
| Visuelle Tonhinweise | Randanzeigen für Warntöne (Gefahr von links oder rechts) |
| Spielgeschwindigkeit | 70, 85, 100 % in der Kampagne. Im Tiefenlauf erlaubt, aber eigene Bestenlisten-Kategorie |
| Schwierigkeit | Kampagne: Entspannt, Normal, Fordernd. Ändert Gegnerleben und Schild, nicht die Belohnungen |
| Automatische Fähigkeit | Fähigkeit löst selbst aus |
| Eingabegeräte | Gamepad, Tastatur, Schalterzugriff über große Zwei-Tasten-Steuerung |

**Allgemein:** Sprache, Schadenszahlen, Tipps, Bestätigungsdialoge.

**Aktualisierung:** Aktuelle Version, „Nach Aktualisierung suchen“, automatische Prüfung an/aus, nur im WLAN herunterladen.

**Daten und Datenschutz:** Hinweis, dass außer der Versionsabfrage bei GitHub (dabei wird die IP-Adresse sichtbar) keine Daten das Gerät verlassen, Spielstand exportieren und importieren (Datei), Spielstand löschen (doppelte Bestätigung), Cache leeren.

**Info:** Version, Lizenzen der verwendeten Assets und Schriften, Mitwirkende.

**Zurücksetzen:** Je Kategorie und insgesamt.

---

## 13. Technische Architektur

### 13.1 Engine-Vergleich

Bewertung 1 (schwach) bis 5 (stark), bezogen auf dieses Projekt.

| Kriterium | Unity 6 | Godot 4 | Unreal 5 | Defold | Flutter/Flame |
|-----------|---------|---------|----------|--------|---------------|
| Grafikqualität (stilisiertes 3D) | 5 | 4 | 5 | 2 | 1 |
| Leistung auf Android | 4 | 4 | 2 | 5 | 3 |
| Entwicklungsaufwand allein | 3 | 5 | 1 | 3 | 3 |
| Erweiterbarkeit, datengetrieben | 4 | 5 | 4 | 3 | 3 |
| 2D und 3D | 5 | 5 | 3 | 2 | 1 |
| UI-Werkzeuge | 3 | 5 | 3 | 3 | 5 |
| APK-Bau und Paketgröße | 4 | 5 | 2 | 5 | 4 |
| Wartbarkeit, Lizenzrisiko | 3 | 5 | 3 | 4 | 4 |
| Eignung für KI-gestützte Entwicklung (Textdateien) | 2 | 5 | 1 | 4 | 5 |
| **Summe** | **33** | **43** | **24** | **31** | **29** |

### 13.2 Empfehlung: Godot 4 (aktuelle stabile 4.x-Version), GDScript mit statischer Typisierung, Mobile-Renderer

Begründung:

1. **Textbasierte Projektdateien:** Szenen (`.tscn`) und Ressourcen (`.tres`) sind lesbarer Text. Das passt zur KI-gestützten Arbeit und zu Versionskontrolle. Unity-Szenen und Prefabs sind dafür deutlich sperriger.
2. **Ressourcen-System:** Eigene Ressourcenklassen sind genau das datengetriebene Modell, das Waffen, Bauteile, Gegner und Skins brauchen.
3. **UI:** Das Control- und Theme-System ist für menülastige Spiele sehr gut geeignet.
4. **Keine Lizenzkosten, kein Konto, MIT-Lizenz:** Kein Risiko durch Preisänderungen.
5. **Kleine APK, schneller Export:** Ein-Klick-Export, kurze Testzyklen auf dem Gerät.

Ehrliche Nachteile:

- Weniger fertige Mobil-Plugins (Werbung, Käufe, Play Games) als Unity. Für 1.0 unerheblich (A4), später relevant.
- 3D-Leistung auf sehr schwachen Geräten erfordert Disziplin (siehe Abschnitt 15).
- Kleinerer Asset-Markt.

**Warum GDScript statt C#:** Beste Android-Unterstützung, schnellste Iteration, kleinere APK. Leistungskritische Stellen (Projektile) werden über Objekt-Pools und MultiMesh gelöst, nicht über Sprachwechsel.

**Wann Unity die bessere Wahl wäre:** Wenn Werbenetzwerke und Echtgeld-Käufe von Anfang an zentral wären oder ein Team mit Unity-Erfahrung vorhanden ist.

### 13.3 Architektur

```
┌─────────────────────────────────────────────────────────────┐
│ Darstellung: Szenen, UI-Bildschirme, Effekte, Ton           │
├─────────────────────────────────────────────────────────────┤
│ Spielsysteme: Lauf, Regisseur, Kampf, Waffen, Gegner, Tore  │
├─────────────────────────────────────────────────────────────┤
│ Meta-Systeme: Inventar, Wirtschaft, Fortschritt, Aufträge   │
├─────────────────────────────────────────────────────────────┤
│ Dienste (Autoloads): Speichern, Einstellungen, Ton, Ereignis│
├─────────────────────────────────────────────────────────────┤
│ Daten: Ressourcen-Definitionen (.tres), Balance-Tabellen    │
└─────────────────────────────────────────────────────────────┘
```

Grundsätze:

- **Definition und Zustand getrennt:** Definitionen (`WeaponPartDef`, `EnemyDef`) sind unveränderliche Ressourcen im Paket. Zustand (`WeaponInstance`, `PlayerProfile`) ist reines Datenobjekt im Speicherstand und verweist per ID auf Definitionen.
- **Stabile IDs:** Jede Definition hat eine feste Text-ID. Speicherstände verweisen nie auf Dateipfade.
- **Spiellogik ohne Szenenbaum:** Wirtschaft, Generator, Schadensberechnung und Fortschritt sind reine Skriptklassen. Dadurch ohne Gerät testbar und als Balance-Simulation ausführbar.
- **Wenige Autoloads:** `SaveService`, `Settings`, `AudioDirector`, `Events` (Signalbus), `Content` (Definitions-Register). Alles andere lebt in Szenen.
- **Verhalten durch Komposition:** Schussmuster, Projektilbewegung und Treffereffekt sind je eine kleine Strategieklasse. Eine Waffe ist die Kombination aus drei bis fünf solcher Bausteine. Neue Bauteile benötigen meist nur einen Datensatz, gelegentlich einen neuen Baustein.
- **Determinismus:** Eigene Zufallsquelle mit Startwert für Generator und Regisseur. Ermöglicht Tagesläufe, Build-Codes und reproduzierbare Fehlerberichte.

### 13.4 Android-Themen

| Thema | Lösung |
|-------|--------|
| Lebenszyklus | Bei Pause-Benachrichtigung der App: Spiel pausieren, Ton stoppen, Spielstand schreiben. Bei Rückkehr: Pausemenü zeigen, nicht direkt weiterlaufen |
| Prozessende im Hintergrund | Laufzustand des Tiefenlaufs wird an jedem Sektorende gesichert und kann fortgesetzt werden |
| Bildschirmgrößen | Hochformat fest, Streckmodus mit erweiterbarer Höhe (18:9 bis 21:9), Tablets mit breiteren Rändern, sichere Bereiche über die Display-Abfrage |
| Faltgeräte und Mehrfenster | Größenänderung wird unterstützt, Lauf pausiert beim Wechsel |
| Wärme und Akku | Bildratenlimit, Energiesparmodus, Menüs mit 30 Bildern, kein Rendern im Hintergrund |
| Zielplattform | Mindestens Android 8 (API 26), Ziel-API nach aktueller Play-Vorgabe, arm64 und armv7, 16-KB-Speicherseiten |
| Offline | Das Spiel selbst läuft vollständig offline. Netzwerk nur für die Aktualisierungsprüfung (13.6). Ohne Netz entfällt die Prüfung stillschweigend |
| Aktualisierungen | Speicherstand liegt im App-Datenordner und überlebt Updates. Gleicher Signaturschlüssel für alle Versionen, Schlüssel doppelt gesichert |

### 13.5 Versionsverwaltung, automatische Tests und Veröffentlichung

**Branch-Modell:**

| Branch | Zweck | Regeln |
|--------|-------|--------|
| `main` | Veröffentlichter Stand. Jeder Merge erzeugt eine neue APK | Geschützt: kein direkter Push, nur Pull Request von `develop` oder `hotfix/*`, Tests müssen grün sein |
| `develop` | Sammelstand der fertigen Features | Geschützt: nur Pull Request, Tests müssen grün sein |
| `feature/<name>` | Ein Feature je Branch, abgezweigt von `develop` | Kurzlebig, wird nach dem Merge gelöscht |
| `fix/<name>` | Fehlerbehebung, abgezweigt von `develop` | Wie Feature |
| `hotfix/<name>` | Dringende Korrektur am veröffentlichten Stand, abgezweigt von `main` | Merge nach `main` und zurück nach `develop` |

Ablauf: `feature/x` → Pull Request nach `develop` (Squash-Merge, ein Commit je Feature) → wenn `develop` veröffentlichungsreif ist: Versionsnummer erhöhen, Pull Request `develop` → `main` (Merge-Commit) → APK wird gebaut und veröffentlicht.

**Versionsnummern:**

- Versionsname nach dem Schema `MAJOR.MINOR.PATCH` (zum Beispiel `0.3.1`), gepflegt an genau einer Stelle (Datei `version.txt`). Vor 1.0 beginnen alle Versionen mit `0.`.
- Versionscode (die ganze Zahl, an der Android „neuer oder älter“ erkennt) wird in der Pipeline automatisch aus der Anzahl der Commits auf `main` berechnet. Er steigt dadurch immer.
- Git-Tag und Release heißen `v<Versionsname>`.
- Die Teststufe eines Pull Requests nach `main` schlägt fehl, wenn die Versionsnummer nicht erhöht wurde oder das Tag schon existiert. So kann keine Veröffentlichung eine alte überschreiben.

**Pipelines (GitHub Actions, für öffentliche Repositorys kostenlos):**

| Workflow | Auslöser | Stufen |
|----------|----------|--------|
| `ci.yml` | Jeder Pull Request nach `develop` oder `main` | **Test:** Einheitentests (GUT, ohne Grafik), Datenprüfung aller Definitionen, Kurzlauf der Balance-Simulation, Probe-Export einer Debug-APK (beweist, dass der Bau funktioniert). Bei Ziel `main` zusätzlich Versionsprüfung |
| `release.yml` | Push auf `main` (also jeder Merge) | **1. Test:** dieselben Prüfungen wie oben. **2. Bau:** signierte Release-APK, nur wenn Stufe 1 grün ist. **3. Veröffentlichung:** Tag setzen, GitHub Release anlegen mit APK, Prüfsummendatei (SHA-256) und Änderungsliste aus den Pull-Request-Titeln |
| `nightly.yml` (optional) | Push auf `develop` | Debug-APK als herunterladbares Artefakt des Laufs, kein Release. Zum Testen vor der Veröffentlichung |

Die Stufen hängen voneinander ab: schlägt die Teststufe fehl, wird weder gebaut noch veröffentlicht.

**Bauumgebung:** Godot ohne Grafikoberfläche plus Export-Vorlagen in exakt der Version des Projekts, Android-SDK, JDK 17. Die Godot-Version steht in einer Datei und wird von Pipeline und Entwickler gleich verwendet.

**Signaturschlüssel und Geheimnisse:**

- Der Release-Schlüssel wird einmalig lokal erzeugt und liegt niemals im Repository.
- In GitHub als verschlüsselte „Secrets“ hinterlegt: Schlüsseldatei (Base64), Alias, Passwörter. Die Pipeline schreibt die Datei nur für die Dauer des Baus.
- Sicherung des Schlüssels an zwei Orten außerhalb von GitHub. Geht er verloren, kann keine installierte App mehr aktualisiert werden: alle Spieler müssten deinstallieren und verlören ihren Spielstand.
- Workflows aus fremden Forks erhalten keine Secrets (GitHub-Standard, wird nicht geändert).

**Was im öffentlichen Repository nicht landen darf:** Schlüsseldateien, Passwörter, Godot-Zwischenordner (`.godot/`), Bauausgaben, Assets mit Lizenzen, die keine Weitergabe erlauben. Eine `.gitignore` deckt das von Beginn an ab.

**Große Dateien:** Entgegen der ursprünglichen Planung zunächst **ohne Git LFS**. GitHub begrenzt Speicher und Datenverkehr für LFS im kostenlosen Tarif, und jeder Pipeline-Lauf würde davon verbrauchen. Der stilisierte Grafikstil erzeugt kleine Dateien. Erst wenn das Repository etwa 1 GB erreicht, wird neu entschieden.

### 13.6 Aktualisierung aus der App

**Ablauf aus Sicht des Spielers:**

1. Beim Start prüft die App höchstens einmal je 24 Stunden, ob eine neuere Version existiert. Zusätzlich gibt es in den Einstellungen den Knopf „Nach Aktualisierung suchen“.
2. Gibt es eine neuere Version, erscheint im Hauptmenü ein Hinweis: „Version 0.4.0 verfügbar“ mit Änderungsliste und Dateigröße.
3. Tipp auf „Aktualisieren“ lädt die APK mit Fortschrittsanzeige herunter.
4. Nach dem Download öffnet sich der Installationsdialog von Android. Der Spieler bestätigt, die App startet neu, der Spielstand bleibt.

Nie während eines Laufs, nie erzwungen. „Später“ blendet den Hinweis bis zur nächsten Version aus.

**Technik:**

| Schritt | Umsetzung |
|---------|-----------|
| Versionsabfrage | Abruf von `https://api.github.com/repos/<Benutzer>/<Repository>/releases/latest` ohne Anmeldung. Vergleich des Tags mit der eigenen Version |
| Download | APK-Datei des Releases in den privaten Cache-Ordner der App |
| Prüfung | SHA-256 der geladenen Datei gegen die Prüfsummendatei des Releases. Zusätzlich prüft Android selbst, dass die Signatur zur installierten App passt. Eine fremd signierte Datei wird vom System abgelehnt |
| Installation | Übergabe an den Paketinstaller von Android. Dafür ist ein kleines Android-Plugin für Godot nötig (Kotlin, etwa 100 Zeilen), weil GDScript diesen Systemaufruf nicht direkt kann |
| Berechtigungen | `INTERNET` und `REQUEST_INSTALL_PACKAGES`. Der Spieler muss einmalig in den Android-Einstellungen „Installation aus dieser Quelle zulassen“ erlauben. Die App führt beim ersten Mal dorthin |
| Aufräumen | Geladene APK wird nach erfolgreicher Aktualisierung gelöscht |

**Fehlerfälle:** Kein Netz, Abfragelimit von GitHub erreicht (60 Abfragen je Stunde und Anschluss), abgebrochener Download, falsche Prüfsumme, zu wenig Speicher, Erlaubnis verweigert. In jedem Fall eine verständliche Meldung, das Spiel bleibt nutzbar, und ein Knopf öffnet ersatzweise die Release-Seite im Browser.

**Einstellungen dazu:** Automatische Prüfung an/aus, nur im WLAN herunterladen (Standard: an).

**Grenzen:**

- Android zeigt bei jeder Installation seinen Bestätigungsdialog. Eine völlig stille Aktualisierung ist für Apps außerhalb eines Stores nicht möglich.
- Play Protect kann bei unbekannten Apps warnen. Das lässt sich ohne Store nicht abstellen.
- Falls das Spiel später in den Play Store soll, muss diese Funktion in der Store-Variante abgeschaltet sein. Sie wird deshalb hinter einem Bauschalter gekapselt.
- Datenschutz: Bei der Abfrage sieht GitHub die IP-Adresse des Geräts. Es werden keine weiteren Daten gesendet. Das steht im Datenschutzhinweis der App.

---

## 14. Balancing-Konzept

### 14.1 Wertbudget für Waffen

Jede Waffe hat einen Zielwert für Schaden pro Sekunde:

```
Ziel-DPS = Basis-DPS × Seltenheitsfaktor × 1,08^Upgrade-Stufe
```

Das Gehäuse verteilt dieses Budget auf Schaden je Treffer, Feuerrate und Projektilanzahl. Läufe und Kerne tragen Kostenfaktoren: Ein Fächerlauf mit fünf Projektilen teilt den Schaden nicht durch fünf, sondern durch etwa 3,5, weil selten alle treffen. Flächen-, Durchschlags- und Zielsuch-Eigenschaften kosten Budget. Die Faktoren stehen in einer Tabelle und werden über die Simulation (Abschnitt 19) kalibriert.

### 14.2 Kampagnenkurve

- Gegnerleben je Level: `Basis × 1,09^Level`, mit Stufen an Weltgrenzen.
- Erwartete Spielerstärke: Ein Spieler, der seine Münzen in eine Waffe steckt, liegt 10–20 % über dem Bedarf. Wer breit streut, liegt knapp darunter und wird durch die Aufhol-Regel gestützt.
- Kein Level darf zwingend das Wiederholen alter Level verlangen. Prüfkriterium in der Simulation.

### 14.3 Tore im Lauf

- Additive Tore früh stark, multiplikative Tore spät stark. Das ist eine echte Abwägung.
- Obergrenzen je Lauf für Projektilanzahl und Feuerrate. Überschuss wird in Schaden umgerechnet. Das schützt die Bildrate und verhindert unlesbares Chaos.

### 14.4 Skalierung im Tiefenlauf

```
Gegnerleben(s)    = L0 × 1,13^s
Gegnerdichte(s)   = D0 × (1 + 0,04 × s), gedeckelt
Spielerstärke(s)  ≈ Arsenalstärke × 1,10^s   (durchschnittliche Kartenwahl)
```

Die Gegnerkurve wächst schneller als die Spielerkurve. Der Schnittpunkt hängt von der Arsenalstärke ab. Zielwerte: neuer Spieler Sektor 8–12, nach 10 Stunden Sektor 25–35, nach 50 Stunden Sektor 60–80.

Technische Absicherung für sehr lange Läufe:

- Alle Kampfwerte als 64-Bit-Gleitkommazahlen, Anzeige mit Kürzeln (K, M, B, T, danach aa, ab …).
- Gedeckelte Mengen (Gegner gleichzeitig, Projektile), Wachstum danach nur noch über Werte.
- Ab Sektor 100 „Überlast“: Statt nur mehr Leben kommen in festen Abständen neue Gegnermerkmale und Mutator-Stufen hinzu, damit sich die Tiefe anders anfühlt und nicht nur länger dauert.
- Fundstärke im Lauf skaliert mit der Tiefe. Beim dauerhaften Behalten wird die Waffe auf die Kontostufe normalisiert, Seltenheit und Bauteile bleiben. So zerstört ein Glückslauf nicht die Wirtschaft.

### 14.5 Upgrade-Wirtschaft

| Größe | Formel | Ziel |
|-------|--------|------|
| Upgrade-Kosten | `Basis × 1,15^Stufe` | Stufe 20 kostet etwa 16-mal so viel wie Stufe 1 |
| Upgrade-Wirkung | `+8 %` je Stufe, multiplikativ | Stufe 20 ergibt etwa 4,7-fache Wirkung |
| Münzeinkommen | wächst etwa 6 % je Level | Zeit bis zum nächsten Upgrade steigt langsam von 1 auf 3 Läufe |
| Seltenheitsaufstieg | Schrott: 50, 150, 400, 1.000, 2.500 | Mythisch ist ein Langzeitziel von mehreren Wochen |

### 14.6 Fundchancen

Grundgewichte einer Bauteilkiste:

| Seltenheit | Kampagne | Tiefenlauf Sektor 1 | Zuwachs je 10 Sektoren |
|------------|----------|---------------------|------------------------|
| Common | 55 % | 50 % | sinkt |
| Uncommon | 27 % | 28 % | sinkt leicht |
| Rare | 12 % | 14 % | +2 Punkte |
| Epic | 4,5 % | 6 % | +1,5 Punkte |
| Legendary | 1,3 % | 1,8 % | +0,6 Punkte |
| Mythic | 0,2 % | 0,2 % (ab Sektor 75: 0,5 %) | +0,1 Punkte |

Pech-Schutz: Spätestens jede 10. Kiste ist mindestens Rare, spätestens jede 40. mindestens Epic, spätestens jede 120. mindestens Legendary. Die Chancen sind im Spiel einsehbar.

### 14.7 Werkzeuge

- Alle Balance-Werte in Tabellen-Ressourcen, keine Zahlen im Code.
- Balance-Simulation ohne Grafik: spielt 10.000 Läufe mit einfachen Strategien (gierig, zufällig, spezialisiert) und gibt Fortschrittskurven aus.
- Entwicklermenü im Testbau: Münzen setzen, Level springen, Waffe erzeugen, Sektor wählen, Unverwundbarkeit, Zeitraffer.

---

## 15. Datenmodelle und Speicherung

### 15.1 Definitionen (im Paket, unveränderlich)

```
WeaponPartDef   id, slot, familie, seltenheit_min, wertmodifikatoren,
                verhaltensbausteine[], modell, andockpunkte, mindesttiefe, ausschlüsse[]
AffixDef        id, wertebereich, verhalten, konflikte[], kostenfaktor
UniqueTraitDef  id, verhalten, beschreibung
EnemyDef        id, familie, leben, tempo, verhalten, bedrohungskosten, mindesttiefe
GateDef         id, typ, wirkung, gewicht
SegmentDef      id, szene, länge, schwierigkeit, tags[], welt
LevelDef        id, welt, segmente[], boss, ziele[], belohnungen
MutatorDef      id, regeländerung, mindesttiefe
CardDef         id, seltenheit, wirkung, synergie_tags[]
SkinDef         id, kategorie, shader_parameter, effekt_overrides, freischaltung
AchievementDef  id, bedingung, stufen[], belohnung
BalanceTable    kurven und konstanten
```

### 15.2 Spielstand (Zustand)

```json
{
  "version": 7,
  "erstellt": "2026-11-11T10:00:00Z",
  "profil": { "level": 12, "xp": 840, "muenzen": 5230, "schrott": 310, "prismen": 45 },
  "waffen": [
    { "uid": "w_00017", "seed": 9182736, "gehaeuse": "chassis_smg_a", "lauf": "barrel_fan3",
      "kern": "core_cryo", "chip": "chip_ricochet", "seltenheit": 3,
      "affixe": [["crit_chance", 0.07], ["proj_speed", 0.12]],
      "stufen": { "schaden": 8, "feuerrate": 5 }, "skin": "skin_neon_02", "kills": 4312 }
  ],
  "bauteile": { "barrel_fan3": 2, "core_shock": 1 },
  "ausruestung": { "aktiv": "w_00017", "sets": [] },
  "kampagne": { "sterne": { "w1_l01": 3, "w1_l02": 2 } },
  "tiefenlauf": { "rekord": 27, "meilensteine": [10, 20], "laufender_lauf": null },
  "skins": ["skin_neon_02"],
  "meisterschaft": { "smg": 3400 },
  "erfolge": { "kills_total": 2 },
  "kodex": ["core_cryo", "syn_shardlance"],
  "auftraege": { "tag": "2026-11-11", "liste": [] },
  "pech_schutz": { "seit_rare": 4, "seit_epic": 22, "seit_legendary": 61 },
  "statistik": { "spielzeit_s": 18200, "laeufe": 143 }
}
```

Einstellungen liegen in einer eigenen Datei, damit ein defekter Spielstand nie die Einstellungen mitreißt und umgekehrt.

### 15.3 Sichere Speicherstrategie

1. **Atomar schreiben:** In temporäre Datei schreiben, dann umbenennen. Ein Absturz mitten im Schreiben zerstört nie den gültigen Stand.
2. **Sicherungskopien:** Die letzten drei gültigen Stände bleiben erhalten. Beim Laden wird bei Fehler automatisch der nächstältere genommen und der Spieler informiert.
3. **Prüfsumme:** Erkennt beschädigte Dateien. Dient nicht dem Schutz vor Manipulation, das ist in einem Offline-Spiel nicht sinnvoll durchsetzbar.
4. **Versionierung:** Jede Strukturänderung erhöht `version`. Eine Kette kleiner Umwandlungsfunktionen (`v6 → v7`) hebt alte Stände an. Jede Umwandlung hat einen Test mit einem echten alten Stand.
5. **Unbekannte IDs:** Verweist ein Stand auf eine entfernte Definition, wird ein Ersatz gesetzt und der Gegenwert erstattet. Kein Absturz.
6. **Zeitpunkte:** Nach jedem Lauf, nach jedem Kauf, bei App-Pause. Nicht in jedem Bild.
7. **Export und Import:** Als Datei über den Android-Dateidialog. Das ist die Brücke bis zu Cloud-Speicherständen.
8. **Cloud später:** Der Speicherdienst erhält eine schmale Schnittstelle (laden, speichern, Zeitstempel). Eine Umsetzung für Play Games Saved Games kann später ergänzt werden, mit Konfliktregel „höherer Fortschritt gewinnt, Spieler bestätigt“.

---

## 16. Leistung und Optimierung

### Zielwerte

| Geräteklasse | Beispiel | Ziel |
|--------------|----------|------|
| Niedrig | 3 GB RAM, Einsteiger-Chip von 2020 | 30 Bilder stabil auf „Niedrig“ |
| Mittel | 6 GB RAM, Mittelklasse-Chip | 60 Bilder stabil auf „Mittel/Hoch“ |
| Hoch | Aktuelle Oberklasse | 90–120 Bilder auf „Ultra“ |

| Kennzahl | Budget |
|----------|--------|
| Zeichenaufrufe | unter 150 (Mittel) |
| Sichtbare Dreiecke | unter 150.000 |
| Aktive Projektile | höchstens 400, darüber Zusammenfassung zu stärkeren Projektilen |
| Aktive Gegner | höchstens 120 |
| Arbeitsspeicher | unter 600 MB |
| Paketgröße | unter 150 MB |
| Kaltstart bis Menü | unter 5 Sekunden (Mittelklasse) |
| Ladezeit in einen Lauf | unter 2 Sekunden |

### Maßnahmen

- **Objekt-Pools** für Projektile, Gegner, Effekte, Schadenszahlen. Keine Erzeugung zur Laufzeit im Kampf.
- **MultiMesh** für Projektile und Schwarmgegner: ein Zeichenaufruf für hunderte Instanzen.
- **Eigene Treffererkennung** für Projektile: Bahnen sind vorhersehbar, daher einfache Abstandsprüfung in Spur-Rastern statt Physik-Engine.
- **Segment-Streaming:** Nur zwei bis drei Segmente gleichzeitig geladen, Rest im Nebel.
- **Shader:** Wenige, parametrisierte Materialien. Shader beim Start vorwärmen, um Ruckler beim ersten Effekt zu vermeiden.
- **Texturen:** Atlanten, ETC2/ASTC-Kompression, kleine Auflösungen durch den stilisierten Look.
- **Ton:** OGG für Musik (gestreamt), kurze WAV für Effekte, Stimmenlimit.
- **Adaptive Qualität (optional):** Sinkt die Bildrate dauerhaft unter das Ziel, wird die Render-Skalierung schrittweise reduziert.
- **Messung vor Optimierung:** Leistungsanzeige im Testbau (Bildzeit, Zeichenaufrufe, Objektzahlen), Belastungsszene „schlimmster Fall“ als fester Maßstab.

---

## 17. Projekt- und Ordnerstruktur

```
frontline/
├─ .github/workflows/         ci.yml, release.yml, nightly.yml
├─ .gitignore
├─ version.txt                Versionsname, einzige Quelle
├─ project.godot
├─ export_presets.cfg         ohne Passwörter
├─ android/plugins/updater/   Kotlin-Plugin für die Installation der APK
├─ README.md
├─ PROJEKTPLAN.md
├─ docs/                      Designnotizen, Balance-Tabellen, Entscheidungen
├─ addons/                    Test-Framework (GUT), ggf. spätere Plugins
├─ assets/
│  ├─ models/  (weapons/parts, enemies, environment)
│  ├─ textures/
│  ├─ shaders/
│  ├─ vfx/
│  ├─ audio/   (music, sfx/weapons, sfx/ui, sfx/enemies)
│  ├─ fonts/
│  └─ ui/      (icons, theme.tres)
├─ data/                      Alle Definitionen als .tres
│  ├─ weapons/ (chassis, barrels, cores, chips, affixes, uniques)
│  ├─ enemies/
│  ├─ gates/
│  ├─ cards/
│  ├─ mutators/
│  ├─ skins/
│  ├─ levels/  (world_1 … world_5)
│  ├─ segments/
│  ├─ progression/ (level_rewards, achievements, missions)
│  └─ balance/
├─ src/
│  ├─ core/        (events, content_registry, rng, big_number_format)
│  ├─ services/    (save_service, settings, audio_director, update_service)
│  ├─ defs/        (Ressourcenklassen der Definitionen)
│  ├─ combat/      (damage, projectiles, behaviours/pattern|motion|on_hit)
│  ├─ weapons/     (weapon_instance, generator, forge)
│  ├─ enemies/
│  ├─ run/         (run_controller, track, gates, director)
│  ├─ meta/        (economy, inventory, progression, quests, codex, mastery)
│  └─ ui/          (screens/, widgets/, hud/)
├─ scenes/
│  ├─ boot.tscn, main_menu.tscn, run.tscn
│  ├─ segments/
│  ├─ enemies/
│  └─ ui/
├─ tests/
│  ├─ unit/        (economy, generator, save_migration, damage)
│  ├─ sim/         (balance_sim.gd, ohne Grafik ausführbar)
│  └─ fixtures/    (alte Spielstände für Migrationstests)
└─ tools/          (Editor-Skripte: Datenprüfung, Levelbau-Helfer, Export-Skript)
```

Versionskontrolle: Git ab dem ersten Tag, öffentliches GitHub-Repository, Branch-Modell und Pipelines nach 13.5. Zunächst ohne Git LFS.

---

## 18. Roadmap und Priorisierung

Aufwand in Personentagen (PT, je 8 Stunden) bei einem Entwickler. Kalenderdauer bei 10–15 Stunden pro Woche in Klammern.

| Meilenstein | Inhalt | Ergebnis | Aufwand |
|-------------|--------|----------|---------|
| **M0 Vorproduktion** | Engine einrichten, Android-Export auf echtem Gerät, Stilprobe (eine Waffe, ein Gegner, ein Segment), Referenz selbst spielen. Git-Repository mit `main` und `develop`, Branch-Schutz, Signaturschlüssel, Pipelines `ci.yml` und `release.yml`, Aktualisierung aus der App | Leere App läuft auf dem Handy, Stil bestätigt. Ein Merge nach `main` erzeugt ein Release, und die installierte App aktualisiert sich darauf | 10 PT (3–4 Wochen) |
| **M1 Prototyp Kernschleife** | Bahn, Lenkung, Auto-Feuer, 3 Tortypen, 3 Gegner, ein Level mit Boss, Grauklotz-Grafik | Antwort auf die Frage „Macht es Spaß?“ | 12 PT (3–4 Wochen) |
| **M2 Vertikaler Schnitt** | Modulares Waffensystem (4 Gehäuse, 4 Läufe, 4 Kerne, 8 Chips), Speichern, Münzen, Upgrades, Arsenal-Bildschirm, Ergebnisseite, endgültiger Look für eine Welt, Grundton | Ein Stück Spiel in Endqualität | 25 PT (7–9 Wochen) |
| **M3 MVP** | 15 Kampagnenlevel, Tiefenlauf Grundversion (Regisseur, Karten, Zwischenboss, Sicherungspunkt), Spieler-Level, Raritäten, Generator, 10 Skins, Einstellungen Basis, Barrierefreiheit Basis | Erste extern testbare APK | 30 PT (8–10 Wochen) |
| **M4 Alpha (Inhalt)** | Welten 2–3, Schmiede vollständig, Shop, Erfolge, Aufträge, Meisterschaft, Kodex, Mutatoren und Ereignisse, volle Einstellungen | Alle Systeme vorhanden | 45 PT (3–4 Monate) |
| **M5 Beta (Feinschliff)** | Welten 4–5, Balance über Simulation und Tester, Leistung auf schwachen Geräten, Musik, Lokalisierung, Einführung, Fehlerbehebung | Inhaltlich vollständig | 40 PT (3 Monate) |
| **M6 Version 1.0** | Abnahmekriterien erfüllt, Store-Material, signierter Bau | Veröffentlichung | 10 PT (3–4 Wochen) |

**Summe: etwa 172 PT.** Bei 10–15 Wochenstunden etwa 12–16 Monate, in Vollzeit etwa 8–9 Monate.

Die Auslieferungskette wird bewusst schon in M0 gebaut, solange die App leer ist. Fehler in Signatur, Versionscode oder Aktualisierung sind dann billig zu finden, und jeder spätere Meilenstein landet automatisch als installierbare Version auf dem Handy. Schätzunsicherheit: ±40 %. Größter Unsicherheitsfaktor sind Grafik- und Tonassets.

**Abbruchpunkt nach M1:** Wenn der Prototyp keinen Spaß macht, wird die Kernmechanik geändert, bevor Inhalte entstehen.

### MVP, 1.0, später

| Stufe | Umfang |
|-------|--------|
| **MVP (M3)** | Kernschleife, 1 Welt mit 15 Leveln und Boss, Tiefenlauf Grundversion, modulare Waffen (etwa 6 Gehäuse, 6 Läufe, 5 Kerne, 15 Chips), 4 Raritäten, Upgrades, Münzen und XP, Arsenal, 10 Skins, sicheres Speichern, Grafikstufen Niedrig/Mittel/Hoch, Lautstärkeregler, Linkshänder-Modus, Farbenblind-Formen |
| **1.0 (M6)** | 5 Welten mit 100 Leveln, 6 Raritäten, etwa 40/15/12/60 Bauteile, Schmiede, Shop, Erfolge, Aufträge, Meisterschaft, Kodex, 40 Mutatoren, Ereignisse, Tageslauf, 60+ Skins, vollständige Einstellungen und Barrierefreiheit, Deutsch und Englisch, Export und Import des Spielstands |
| **Später** | Cloud-Speicherstände, Online-Bestenlisten, Prestige, saisonale Inhaltspakete, neue Welten, Koop-Tageslauf asynchron, weitere Sprachen, Tablet-Querformat |

---

## 19. Feature-Matrix

M = Must-have, S = Should-have, N = Nice-to-have, F = Future. „Erste spielbare Version“ entspricht M1/M2.

| Feature | Priorität | Erste spielbare Version | MVP | 1.0 | Später |
|---------|-----------|:-:|:-:|:-:|:-:|
| Lenkung, Auto-Feuer, Bahn | M | ✔ | ✔ | ✔ | |
| Wert- und Verhaltenstore | M | ✔ | ✔ | ✔ | |
| Gegnerfamilien (3 → 8) | M | 3 | 5 | 8 | |
| Boss | M | 1 | 1 | 5 + Zwischenbosse | |
| Sicheres Speichern mit Versionierung | M | ✔ | ✔ | ✔ | |
| Münzen und Upgrades | M | ✔ | ✔ | ✔ | |
| Modulares Waffensystem | M | Grundform | ✔ | ✔ | |
| Kampagne | M | 1 Level | 15 Level | 100 Level | |
| Tiefenlauf | M | | Grundversion | vollständig | |
| Spieler-Level und XP | M | | ✔ | ✔ | |
| Raritäten | M | | 4 | 6 | |
| Arsenal und Ergebnisseite | M | einfach | ✔ | ✔ | |
| Android-Lebenszyklus, Pause | M | ✔ | ✔ | ✔ | |
| Git-Branch-Modell, Teststufe, automatisches Release bei Merge nach `main` | M | ✔ | ✔ | ✔ | |
| Aktualisierung aus der App (Prüfen, Laden, Installieren) | M | ✔ | ✔ | ✔ | |
| Nightly-Bau von `develop` | N | | ✔ | ✔ | |
| Grafikstufen | M | | 3 Stufen | vollständig | |
| Lautstärkeregler | M | | ✔ | alle Busse | |
| Prozeduraler Waffengenerator | S | | ✔ | ✔ | |
| Risikotore, schießbare Tore | S | | ✔ | ✔ | |
| Skins | S | | 10 | 60+ | |
| Schmiede (Tausch, Aufstieg, Neuwurf) | S | | Tausch | ✔ | |
| Karten-Auswahl im Tiefenlauf | S | | ✔ | ✔ | |
| Mutatoren und Ereignisse | S | | 5 | 40 / 8 | |
| Erfolge, Aufträge, Meisterschaft | S | | | ✔ | |
| Shop | S | | | ✔ | |
| Barrierefreiheit vollständig | S | | Basis | ✔ | |
| Statistiken und Profil | S | | einfach | ✔ | |
| Lokalisierung DE/EN | S | | DE | ✔ | |
| Kodex und Synergien | N | | | ✔ | |
| Tageslauf, Wochenlauf | N | | | ✔ | |
| Schießstand | N | | | ✔ | |
| Build-Codes | N | | | ✔ | |
| Adaptive Musik | N | | | ✔ | |
| Gamepad-Unterstützung | N | | | ✔ | |
| Adaptive Render-Skalierung | N | | | ✔ | |
| Geisterlauf | N | | | | ✔ |
| Cloud-Speicherstände | F | | | | ✔ |
| Online-Bestenlisten | F | | | | ✔ |
| Prestige „Neukalibrierung“ | F | | | | ✔ |
| Inhaltspakete, neue Welten | F | | | | ✔ |
| Monetarisierung (nur Kosmetik) | F | | | | ✔ |

---

## 20. Risiken

| Risiko | Wahrscheinlichkeit | Auswirkung | Gegenmaßnahme |
|--------|-------------------|------------|---------------|
| Umfang sprengt die verfügbare Zeit | Hoch | Hoch | Strikte Stufen (MVP zuerst), Inhalte über Daten statt Code, Abbruchpunkt nach M1 |
| Grafikanspruch ohne Grafiker nicht erreichbar | Mittel | Hoch | Stilprobe in M0, Stil auf Shader und Effekte ausgelegt, CC0-Basis, Budgetentscheidung nach M2 |
| Kombinationen fühlen sich doch gleich an | Mittel | Hoch | Unterscheidbarkeitsregel, wenige aber deutlich verschiedene Verhaltensbausteine, Spieltests |
| Balance im Tiefenlauf kippt (unendliche oder zu kurze Läufe) | Hoch | Mittel | Simulation, Obergrenzen, Kurven in Tabellen |
| Leistung auf schwachen Geräten | Mittel | Mittel | Budgets ab M1 messen, Pools und MultiMesh von Beginn an, ein schwaches Testgerät |
| Speicherstand-Verlust nach Update | Niedrig | Sehr hoch | Atomar schreiben, Sicherungen, Migrationstests mit alten Ständen |
| Verlust des Signaturschlüssels | Niedrig | Sehr hoch | Schlüssel an zwei getrennten Orten sichern |
| Signaturschlüssel oder Passwort gelangt ins öffentliche Repository | Niedrig | Sehr hoch | Nur als GitHub-Secret, `.gitignore` ab dem ersten Commit, Secret-Scanning von GitHub aktiv lassen |
| Godot-Bau in der Pipeline scheitert (Export-Vorlagen, SDK-Versionen) | Mittel | Niedrig | In M0 mit leerer App lösen, Versionen fest vorgeben |
| Aktualisierung scheitert auf einzelnen Geräten (Herstelleroberflächen, verweigerte Erlaubnis) | Mittel | Niedrig | Ersatzweg: Release-Seite im Browser öffnen |
| Fehlerhafte Version wird automatisch veröffentlicht | Mittel | Mittel | Teststufe vor dem Bau, Nightly von `develop` vorher auf dem Gerät prüfen, Hotfix-Weg, fehlerhaftes Release bei GitHub zurückziehen |
| Zu große Nähe zur Referenz | Niedrig | Mittel | Eigener Name, eigener Stil, eigene Inhalte, keine übernommenen Assets, Level oder Bezeichnungen |
| Engine-Fehler oder fehlende Plugins | Niedrig | Mittel | Stabile Version festlegen, Updates nur zwischen Meilensteinen |
| Lizenzfehler bei Assets | Niedrig | Mittel | Lizenzliste von Anfang an in `docs/`, nur CC0 oder dokumentierte Lizenzen |

---

## 21. Teststrategie und Qualität

| Ebene | Was | Wie |
|-------|-----|-----|
| Automatische Einheitentests | Wirtschaft, Schadensformel, Generator (keine verbotenen Kombinationen, Budget eingehalten, Unterscheidbarkeit), Speicher-Migrationen, Pech-Schutz | GUT-Framework, ohne Grafik ausführbar, vor jedem Zusammenführen |
| Datenprüfung | Jede Definition hat eindeutige ID, gültige Verweise, Werte in erlaubten Bereichen | Editor-Skript, läuft mit den Tests |
| Balance-Simulation | Fortschrittskurven, Einkommen je Stunde, Verteilung der Tiefenlauf-Tiefe, dominante Kombinationen | 10.000 simulierte Läufe, Vergleich gegen Zielkorridore |
| Belastungstest | Schlimmster Fall mit Höchstzahl an Gegnern, Projektilen, Effekten | Feste Szene, Bildzeit wird protokolliert |
| Gerätetests | Mindestens drei Geräte: schwach, mittel, stark. Dazu ein Tablet oder Faltgerät | Prüfliste je Meilenstein |
| Lebenszyklus-Tests | Anruf, Bildschirmsperre, App-Wechsel, Prozessende, voller Speicher, Drehen, Mehrfenster | Manuelle Prüfliste |
| Dauerlauf | 60 Minuten Tiefenlauf: Speicherverbrauch, Temperatur, Bildrate | Je Meilenstein ab M3 |
| Spieltests | Erstkontakt ohne Erklärung (5 Personen ab M3), Langzeittester ab M4 | Beobachtung und kurzer Fragebogen |
| Barrierefreiheit | Jede Option einzeln geprüft, Farbenblind-Simulation, größte Schrift in allen Menüs | Prüfliste |
| Regression | Kurze Prüfliste der Kernschleife vor jeder Testversion | 10 Minuten |
| Pipeline | Alle automatischen Tests laufen bei jedem Pull Request. Ohne grüne Teststufe kein Merge und kein Release | GitHub Actions, siehe 13.5 |
| Aktualisierung | Versionsvergleich als Einheitentest. Je Release von Hand: von der Vorversion aus aktualisieren, Spielstand bleibt erhalten | Prüfliste |

Qualitätsregeln: statisch typisiertes GDScript mit Warnungen als Fehler, keine Balance-Zahlen im Code, jede Speicherstruktur-Änderung mit Migration und Test.

---

## 22. Abnahmekriterien

### MVP

1. APK installiert und startet auf Android 8 bis zur aktuellen Version, auf drei Testgeräten.
2. Ein neuer Spieler schließt ohne Erklärung die ersten drei Level ab (4 von 5 Testpersonen).
3. 15 Level und ein Boss sind durchspielbar, ohne alte Level wiederholen zu müssen.
4. Tiefenlauf erreicht Sektor 30 ohne Absturz und ohne Bildrate unter 30 auf dem Mittelklassegerät.
5. Mindestens 100 erzeugte Waffen in Folge sind gültig und paarweise spielerisch verschieden (automatischer Test).
6. App-Abbruch zu jedem Zeitpunkt führt zu keinem Verlust von mehr als dem laufenden Lauf.
7. Spielstand der Vorversion wird korrekt übernommen.
8. Ein Merge nach `main` erzeugt ohne Handarbeit ein GitHub Release mit signierter APK. Bei roter Teststufe entsteht kein Release.
9. Eine von GitHub installierte ältere Version zeigt die neue Version an und aktualisiert sich aus der App heraus, der Spielstand bleibt erhalten.

### Version 1.0

1. **Inhalt:** 100 Level, 5 Bosse, mindestens 40 Gehäuse, 15 Läufe, 12 Kerne, 60 Chips, 60 Skins, 40 Mutatoren, 80 Erfolge.
2. **Leistung:** Zielwerte aus Abschnitt 16 auf allen drei Geräteklassen eingehalten. 60 Minuten Dauerlauf ohne Speicherzuwachs über 10 %.
3. **Stabilität:** Keine bekannten Abstürze. Keine bekannten Fehler mit Fortschrittsverlust.
4. **Wirtschaft:** Simulation bestätigt: mindestens ein Upgrade je Lauf in den ersten 5 Stunden, nach 20 Stunden noch nicht freigeschaltete Inhalte vorhanden, kein Level erfordert Wiederholung alter Level.
5. **Tiefenlauf:** Zwischen Sektor 1–10, 30–40 und 75–85 treten jeweils Inhalte auf, die im vorherigen Bereich nicht vorkamen (automatisch aus den Mindesttiefen prüfbar).
6. **Kein Pay-to-Win:** Keine Spielstärke gegen Echtgeld oder Prismen.
7. **Barrierefreiheit:** Alle Optionen aus Abschnitt 12 vorhanden und geprüft. Spiel ist mit Farbenblind-Modus, größter Schrift und reduzierter Bewegung vollständig spielbar.
8. **Offline:** Alle Spielfunktionen im Flugmodus nutzbar. Einzige Ausnahme ist die Aktualisierungsprüfung, die ohne Netz stillschweigend entfällt.
9. **Lebenszyklus:** Alle Fälle der Prüfliste bestanden.
10. **Recht:** Lizenzliste vollständig, Name geprüft, Datenschutzhinweis vorhanden.
11. **Einstieg:** Vom App-Start bis in den ersten Lauf höchstens 30 Sekunden beim Erststart und zwei Tipps bei jedem weiteren Start.

---

## 23. Nächste Schritte

1. Annahmen A1–A7 und offene Entscheidungen O1–O5 bestätigen oder korrigieren.
2. Referenz 30 Minuten selbst spielen, Abschnitt 2 gegenprüfen.
3. M0 starten: Godot einrichten, Android-Export auf dem eigenen Gerät testen, Git-Repository und Pipelines aufsetzen, Aktualisierung aus der App nachweisen, Stilprobe bauen.
4. M1: Prototyp der Kernschleife, danach Entscheidung „weiter oder Mechanik ändern“.
