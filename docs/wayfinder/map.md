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
- Was von Hand eingerichtet werden muss (nicht über Repo-Dateien gefunden), steht in `README.md`, damit ein neuer Mensch mit neuem Agenten das Projekt aufsetzen kann.
- Git-Schreibvorgänge macht immer der Mensch.

## Decisions so far

<!-- eine Zeile pro geschlossenem Ticket -->

- [Ritter-Bewegung bauen](tickets/12-ritter-bewegung-bauen.md): `Ritter extends Koerper` (gemeinsamer Kasten-Baustein), `Gelaende` liest die `TileMapLayer` ins Raster (Art als Custom Data), Testraum als Startszene; fühlt sich an wie der Prototyp.
- [Musik und Soundeffekte](tickets/10-musik-und-sfx.md): Ritter Krass im Level, Eisen und Eid im Bosskampf mit Horn-Wechsel und Refrain als Song-Moment, Kleiner Ritter für Titel und Game Over; MP3 in Schleife mit Überblenden; Busse Musik/Effekte ohne Absenken; Sounds von Kenney (CC0) plus jsfxr.
- [Kamelhauptmann: Boss-Design](tickets/09-kamelhauptmann.md): Reiter auf Kamel in fester Ein-Bild-Arena, nur in der Knie-Pause verwundbar; Lanzenansturm, Herde von der Seite und aus dem Hintergrund, ab 50 % Spucken; doppelte Warnung; 40/64/88/112 Lebenspunkte; Ross wartet auf die Pause.
- [Agenten-Werkzeuge für Godot auswählen](tickets/19-agenten-werkzeuge-auswaehlen.md): ohne Editor und projektlokal: MindsMaster-Skills, `gda` (CLI), GdUnit4 v6.2.3, Renderer Compatibility, eigener Skill `godot-werkzeuge`; fehlende Typen nur Warnung plus `typen_pruefen.sh`; kein Godot-MCP.
- [Welche Godot-Skills gibt es online für Agenten?](tickets/16-godot-skills-fuer-agenten.md): rund 30 Funde; `godot:godot` und der vorhandene MCP taugen wenig, Vorschlag A ist ein headless Werkzeugkasten (MindsMaster-Skills, `gda`, Screenshot-Test, GdUnit4, eigener TileMapLayer-Skill).
- [Palermo: Aufbau und Gegner](tickets/08-palermo-aufbau-gegner.md): ~10 Bildbreiten in sechs Abschnitten (Hafen, Lagerhäuser, Stadtmauer, Altstadt, Markt, Tor), Säbelkämpfer/Bogenschütze/Schildträger mit 1 Treffer, ein Katapult, Ölfässer, 4 Gefangene, Beilkisten, Kamelherde als Vorgeschmack; gemalt in `TileMapLayer`.
- [Koop-Regeln für 1–4 Spieler](tickets/07-koop-regeln.md): gemeinsamer Vorrat an Leben (3 pro Spieler), Ross bringt Ritter ins aktuelle Bild (keine Checkpoints), Drop-in, zwei Spieler pro Tastatur, Bildrand als Wand, kein Friendly-Fire-Schaden, nur der Boss skaliert; Gefangene +1 Leben.
- [Moveset im Kampf](tickets/06-kampf-moveset.md): Beil & Schild für alle, 1 Treffer = tot, Schlag/Powerschlag nach vorn, oben und unten, Schild vorn/oben, Bumerangaxt mit 3 Ladungen, Blöcke weich/hart/unzerstörbar; Bau mit Abstimmung am echten Ritter.
- [Bewegung zum Anfassen](tickets/05-bewegung-zum-anfassen.md): Broforce-Werte unverändert übernommen (Lauf 110, Sprung 260 bei 0,123 s Halten, Schwerkraft 1100, Wandrutschen 40, Kanten-Flip an); Prototyp auf Branch `prototype/bewegung`.
- [Kollision des Ritters](tickets/11-kollision-des-ritters.md): eigene AABB-Kollision gegen das Block-Raster für alles auf dem Gelände, TileMapLayer nur Anzeige, Körper blockieren sich nicht, Angriffe über `Area2D`, Plattform-Blöcke von Anfang an.
- [Auflösung, Pixel- und Kachelgröße](tickets/04-aufloesung-pixel-kachel.md): 480 × 270 intern, Block 16 px, Ritter 12 × 18 (Sprite 32 × 32), `viewport` + ganzzahlig + 16:9, feste Koop-Zoomstufe.
- [Wie baut man zerstörbares Block-Gelände in Godot 4.7?](tickets/03-zerstoerbares-gelaende.md): TileMapLayer für Bild und Kollision, eigenes Raster als Wahrheit, Einsturz und Trümmer als Eigenbau, AABB-Kollision als Plan B.
- [Wie fühlt sich Broforce-Bewegung an?](tickets/02-broforce-bewegung.md): Broforce-Werte aus Mod-Code (Block 16 px, Figur 12×18, Sprung 260 px/s gehalten, Schwerkraft 1100, Wandrutschen 40 px/s); Kollisionstechnik als eigenes Ticket.
- [Projektstruktur im Godot-Projekt](tickets/01-projektstruktur.md): typisiertes GDScript mit deutschen Namen (Umlaute umgeschrieben), Ordner nach Spielinhalt, wenige Autoloads; Regeln in `CLAUDE.md`, gdtoolkit projektlokal über uv.

## Not yet specified

- HUD: Vorrat an Leben, Bumerangaxt-Ladungen, Boss-Leiste, Spieleranzeige für bis zu 4 Spieler (inkl. „wartet auf ein Leben“).
- Start und Ende eines Durchlaufs: Titelbild (Beitritt per Drop-in ist entschieden), Sieg, Game Over, Neustart, Pause.
- Wut und Berserker aus dem Webspiel: ja oder nein? Offen gelassen in „Moveset im Kampf“.
- Export/Zielplattform des Prototyps.

## Out of scope

- Online/P2P-Mehrspieler: der Prototyp ist rein lokal.
- Ausrüstung, Talente, Orden-Boni, Erfahrung/Stufen: Fortschrittssysteme gehören nicht in einen Ein-Level-Prototyp.
- Weitere Kapitel und Akkon-Verteidigung.
- Wechselnde Figuren beim Befreien von Gefangenen (Broforce-Mechanik): bewusst nicht gewollt.
- Richtige, finale Pixelgrafik.
