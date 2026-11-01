---
title: "Eisen & Eid: Godot-Prototyp"
label: wayfinder:map
---

## Destination

Ein spielbarer Godot-4.7.2-Prototyp: ein kleines Level (Palermo) mit Boss (Kamelhauptmann), Broforce-Physik, zerstörbares Block-Gelände, 1–4 lokale Spieler mit Gamepad und Tastatur, Platzhalter-Pixelgrafik, Song-Musik, überdrehter Ton.

## Notes

- **Ausführung gehört zur Karte**: Sie endet beim spielbaren Prototyp, nicht bei einer Spec. Bau-Tickets sind erlaubt.
- **Spielgefühl hat oberste Priorität.** Die Physik muss sich wie Broforce anfühlen; das Spielgefühl ist der größte Schwachpunkt der Web-Version.
- Vorlage: `index.html` (Webspiel). Kampfsystem und Palermo/Kamelhauptmann dienen als Ausgangspunkt, nicht als Pflicht.
- Ton: überdrehtes Ritter-Mittelalter wie im Song („Scheiß auf geschichtlich akkurat“).
- Grafik: erst Platzhalter-Pixel-Sprites; Aseprite ist installiert.
- Skills für jede Session: `grilling`, `domain-modeling`. Glossar: `GLOSSARY.md` im Repo-Root.
- Tracker: lokale Markdown-Dateien. Karte `docs/wayfinder/map.md`, Tickets `docs/wayfinder/tickets/NN-*.md` (Frontmatter: `type`, `status` open/closed, `assignee` = Claim, `blocked_by` = Ticketnummern). Recherche-Ergebnisse in `docs/wayfinder/research/`. Späterer Umzug zu GitHub Issues möglich.
- Git-Schreibvorgänge macht immer der Mensch.

## Decisions so far

<!-- eine Zeile pro geschlossenem Ticket -->

- [Wie baut man zerstörbares Block-Gelände in Godot 4.7?](tickets/03-zerstoerbares-gelaende.md): TileMapLayer für Bild und Kollision, eigenes Raster als Wahrheit, Einsturz und Trümmer als Eigenbau, AABB-Kollision als Plan B.
- [Wie fühlt sich Broforce-Bewegung an?](tickets/02-broforce-bewegung.md): Broforce-Werte aus Mod-Code (Block 16 px, Figur 12×18, Sprung 260 px/s gehalten, Schwerkraft 1100, Wandrutschen 40 px/s); Kollisionstechnik als eigenes Ticket.
- [Projektstruktur im Godot-Projekt](tickets/01-projektstruktur.md): typisiertes GDScript mit deutschen Namen (Umlaute umgeschrieben), Ordner nach Spielinhalt, wenige Autoloads; Regeln in `CLAUDE.md`, gdtoolkit projektlokal über uv.

## Not yet specified

- Platzhalter-Grafiken selbst: Stil, Animationsliste, Palette (nach Auflösung und Moveset).
- HUD: Leben, Boss-Leiste, Spieleranzeige für bis zu 4 Spieler.
- Start und Ende eines Durchlaufs: Titelbild, Beitritt, Sieg/Niederlage, Neustart.
- Was befreite Gefangene bringen (Extraleben, Heilung, Wiedereinstieg?).
- Bau-Tickets für Level, Gegner und Boss, sobald deren Design steht.
- Export/Zielplattform des Prototyps.

## Out of scope

- Online/P2P-Mehrspieler: der Prototyp ist rein lokal.
- Ausrüstung, Talente, Orden-Boni, Erfahrung/Stufen: Fortschrittssysteme gehören nicht in einen Ein-Level-Prototyp.
- Weitere Kapitel und Akkon-Verteidigung.
- Wechselnde Figuren beim Befreien von Gefangenen (Broforce-Mechanik): bewusst nicht gewollt.
- Richtige, finale Pixelgrafik.
