---
title: Agenten-Werkzeuge für Godot auswählen
type: grilling
status: closed
assignee: fjw
blocked_by: [16]
---

## Question

Welche Skills, Plugins und MCP-Server aus der Recherche „Welche Godot-Skills gibt es online für Agenten?“ werden projektlokal eingerichtet, was fliegt raus (`godot:godot`, vorhandener Godot-MCP), und welche Lücken schließen wir mit eigenen Skills (z. B. `TileMapLayer` headless)?

## Hinweise

- Grundlage: `docs/wayfinder/research/16-godot-skills-fuer-agenten.md`, Optionen A–D.
- Vor der Entscheidung prüfen: GdUnit4-Version für 4.7.2, Gamepad-Geräte-Nummer in `gda`, ob der Compatibility-Renderer für Screenshots genügt.
- Installieren macht der Mensch oder ein Agent nach ausdrücklicher Freigabe; nur projektlokal.
- Alles, was nicht automatisch über Dateien im Repo gefunden wird und von Hand installiert werden muss, kommt mit Schritten in `README.md` (Regel in `CLAUDE.md`).

## Resolution

Entschieden im Gespräch und in derselben Session eingerichtet, 2026-11-01:

| Thema | Entscheidung |
|---|---|
| Grundrichtung | Werkzeugkasten ohne Editor, nur im Projekt (Option A der Recherche). Der Mensch kann den Editor weiter benutzen; bei Änderungen eines Agenten lädt er die Datei neu. |
| Wissen | Plugin `godot-skills` (MindsMaster), über `extraKnownMarketplaces`/`enabledPlugins` in `.claude/settings.json`. `godot:godot` entfernt (veraltet, PlayGodot läuft nicht mit 4.7.2). |
| gda | Nur als Kommandozeile, `uv add --dev gda` (0.24.2), `requires-python >=3.13`, `GDA_GODOT=godot` in `.claude/settings.json`. Kein MCP. Live-Daemon nach jedem Test mit `gda daemon uninstall` entfernen; `addons/gda_harness/` ist ignoriert. gda sendet keine Gamepad-Ereignisse mit Geräte-Nummer. |
| Strenge Typen | gda-Skripte sind untypisiert und scheitern sonst. Darum `untyped_declaration=1` (Warnung) statt 2. Prüfung über `typen_pruefen.sh` (kurz `override.cfg` mit Stufe 2, `--check-only` auf alle eigenen Skripte). Ersetzt die Einstellung aus „Projektstruktur im Godot-Projekt“. |
| Godot-MCP | Coding-Solo-MCP abgeschafft; vorerst keine `.mcp.json`. Spätere MCP-Server kommen in `.mcp.json` ins Repo. |
| Tests | GdUnit4 v6.2.3 committet in `godot-project/addons/gdUnit4/`, Plugin eingeschaltet. Läuft mit 4.7.2 unter `xvfb-run`; Gamepad-Test mit `device = 2` geprüft. Berichte in `reports/` ignoriert. |
| Renderer | Compatibility (`gl_compatibility`), damit Screenshots unter Xvfb gehen. |
| Screenshot-Vergleich | Skill `godot-visual-test` (dannroda) aufnehmen. |
| Aseprite | Später, in „Platzhalter-Grafiken zum Anschauen“. |
| Eigener Skill | `.agents/skills/godot-werkzeuge/` mit `zellen_setzen.gd` (TileMapLayer-Zellen ohne Editor, mit Screenshot geprüft), `typen_pruefen.sh`, Klassenreferenz über `godot --doctool .godot-doku` (ignoriert), Live-Test- und Gamepad-Test-Muster, Regeln neben dem offenen Editor. |
| Lint | `gdformatrc`/`gdlintrc` nehmen `addons/` aus. |
| Doku | README (was von Hand einzurichten ist) und `CLAUDE.md` (Prüfschritte, Skill) nachgezogen. |

Vom Menschen noch auszuführen: `npx skills add dannroda/godot-agent-plugins --skill godot-visual-test` (vom Agenten nicht ausführbar, fremder Code) und `claude mcp remove godot`.
