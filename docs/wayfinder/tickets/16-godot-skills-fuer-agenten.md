---
title: Welche Godot-Skills gibt es online für Agenten?
type: research
status: closed
assignee: fjw
blocked_by: []
---

## Question

Welche Skills (Claude-Code-Skills, Agent-Skills, Plugins, MCP-Server) gibt es im Netz, die Agenten befähigen, in Godot 4.7 zu bauen? Für jeden Fund: Quelle, was er kann, Pflegezustand, Passung zu diesem Projekt.

## Hinweise

- Schon vorhanden: Plugin-Skill `godot:godot` (GdUnit4, PlayGodot, Export), Godot-MCP-Server (Szenen und Nodes anlegen, Spiel starten/stoppen, Debug-Ausgabe; **kann keine `TileMapLayer`-Zellen setzen**), eigene Skills `prototype`, `grilling`, `domain-modeling`, `wayfinder` in `.claude/skills/`.
- Besonders gesucht: GDScript 4 mit durchgehenden Typen, TileMapLayer/TileSet ohne Editor, Szenen headless bauen, Tests (GdUnit4), Spiel automatisiert steuern und Screenshots machen, Eingabe mit mehreren Geräten, Pixel-Art/Aseprite-Import.
- Rahmen: Nur projektlokal installierbar (kein globales Installieren), Editor wird nicht von Agenten geöffnet, keine Aufrufe externer Dienste aus dem Spiel.
- Ergebnis: Empfehlung, welche Skills installiert werden sollen, mit Vor- und Nachteilen. Installieren entscheidet der Mensch.
- Recherche-Ergebnis nach `docs/wayfinder/research/16-godot-skills-fuer-agenten.md`.

## Resolution

Recherche vom 2026-11-01: [research/16-godot-skills-fuer-agenten.md](../research/16-godot-skills-fuer-agenten.md) mit rund 30 Funden.

- `godot:godot` stammt aus einem als veraltet markierten Repo. PlayGodot braucht einen Godot-Fork und läuft nicht mit dem offiziellen 4.7.2. Brauchbar bleibt nur der GdUnit4-Teil.
- Der vorhandene Godot-MCP-Server kann keine Zellen setzen, keine Eingaben senden und keine Screenshots machen.
- Vorschlag A (headless, projektlokal): Plugin `godot-skills` (MindsMaster, `--scope project`), `gda[mcp]` über uv (braucht `requires-python >=3.13`), Skill `godot-visual-test` (Screenshots unter `xvfb-run`), GdUnit4 als Addon, eigener Skill für `TileMapLayer` headless und `godot --doctool`.
- Alternativen: B Vollkorn-Fork des MCP (`set_cells`, Gamepad, Screenshots; wenig gepflegt, öffnet Port 9876), C `satelliteoflove/godot-mcp` (braucht offenen Editor), D nur Wissen.
- Offen: Gamepad-Geräte-Nummer in `gda`, Aseprite-Import headless, passende GdUnit4-Version, Screenshots ohne GPU nur mit Compatibility-Renderer. Einige Sterne und Daten fehlen, weil das GitHub-API-Limit erreicht war.

Entscheidung über die Installation: „Agenten-Werkzeuge für Godot auswählen“.
