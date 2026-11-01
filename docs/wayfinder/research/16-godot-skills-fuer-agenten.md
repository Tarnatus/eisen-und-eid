---
ticket: 16-godot-skills-fuer-agenten
title: Welche Godot-Skills gibt es online für Agenten?
stand: 2026-11-01
---

# Welche Godot-Skills gibt es online für Agenten?

## Zusammenfassung

- Es gibt inzwischen sehr viele Godot-Skills und Godot-MCP-Server. Die meisten sind jung, haben wenige Sterne und überschneiden sich stark. Gelesen wurden die README-Dateien (bei einigen auch einzelne `SKILL.md`), nicht nur Suchtreffer.
- Man kann die Funde in drei Gruppen teilen:
  1. **Wissens-Skills**: Sie bringen dem Agenten bei, wie man in Godot 4.x richtig baut (typisiertes GDScript, `TileMapLayer`, Eingabe, Tests). Sie führen selbst nichts aus.
  2. **Werkzeuge, die ohne Editor arbeiten** (headless): Sie bauen Szenen, prüfen Skripte und steuern das laufende Spiel von außen.
  3. **Editor-Brücken**: Sie brauchen einen offenen Godot-Editor mit Addon. Das widerspricht der Regel „Agenten öffnen den Editor nicht“, außer der Mensch lässt den Editor selbst offen.
- **Wichtiger Befund zum Bestehenden:**
  - Der installierte Plugin-Skill `godot:godot` stammt aus dem Repo `Randroids-Dojo/Godot-Claude-Skills`, und das ist **als veraltet markiert**. Der Nachfolger liegt in `Randroids-Dojo/skills` (`plugins/godot`).
  - Sein Teil „PlayGodot“ (Spiel steuern, Screenshots) braucht einen **eigenen Godot-Fork**. Mit dem offiziellen Godot 4.7.2 geht das nicht. Nutzbar bleibt nur der Teil zu GdUnit4.
  - Der installierte MCP-Server `@coding-solo/godot-mcp` (Version 0.1.1 vom Februar 2026) kann weder `TileMapLayer`-Zellen setzen noch Eingaben senden oder Screenshots machen.
- **Godot kann vieles schon selbst, ohne Zusatz:**
  - `godot --doctool <ordner>` legt die komplette Klassenreferenz genau für 4.7.2 als XML ab. Das geht offline und ohne externen Dienst. Lokal geprüft: Die Option ist in der installierten 4.7.2 vorhanden.
  - `--write-movie <datei>.png` mit `--fixed-fps` schreibt Einzelbilder. Das ist eine Screenshot-Quelle ohne Addon.
  - `--headless --script` führt beliebige GDScript-Werkzeuge ohne Editor aus, zum Beispiel ein Skript, das `TileMapLayer`-Zellen setzt und die Szene speichert.
- Auf dem Rechner vorhanden: `godot` 4.7.2, `node`/`npx`, `xvfb-run`, `aseprite`, `.venv` mit Python 3.13. Nicht vorhanden: `gamescope`, `gh`.

## Alle Funde

Legende Passung: ++ sehr gut, + gut, o teilweise, – schlecht. „Push“ heißt: letzter Push laut GitHub-API. „n. e.“ heißt: nicht ermittelt (das GitHub-API-Limit war erschöpft).

### Wissens-Skills (SKILL.md, Plugins)

| Name | URL | Was er kann | Godot | Pflege | Installation | Passung | Risiken |
|---|---|---|---|---|---|---|---|
| **godot-claude-code-skills** (MindsMaster) | https://github.com/MindsMaster/godot-claude-code-skills | 16 Skills, „eingebaute Lösung zuerst“: GDScript mit Typen, 2D (`CharacterBody2D`, `TileMapLayer`, Pixel-Art, Camera2D), Eingabe mit Gamepad und Deadzone, UI, Audio, Ressourcen, Headless-Tests. Jedes Beispiel läuft in der CI gegen Godot 4.7.2. Messung in Evals: 38/39 Aufgaben mit Plugin gelöst, 6/39 ohne. Darunter auch „Kachel-Level mit Graben“. | 4.4 bis 4.7.2 | 2 ★, Push 30.10.2026, MIT | `claude plugin marketplace add …` und `claude plugin install godot-skills@godot-claude-code-skills --scope project` | ++ | Neues Projekt mit wenigen Nutzern. Das Plugin liegt im Cache unter `~/.claude/plugins` (genauso wie das schon installierte `godot:godot`). Führt keinen Code aus. |
| **awesome-gamedev-agent-skills**, Plugin `godot` | https://github.com/gamedev-skills/awesome-gamedev-agent-skills | 16 Godot-Skills, darunter `godot-gdscript`, `godot-2d-movement`, `godot-tilemap` (`TileMapLayer`), `godot-gdscript-headless-testing`. Dazu Plugins für Genres (Platformer) und Disziplinen (Input, Game Feel). | 4.7 | n. e., Apache 2.0 | `claude plugin install godot@awesome-gamedev-agent-skills` | + | Breiter, aber weniger tief geprüft als MindsMaster. |
| **godot-agent-plugins** (dannroda) | https://github.com/dannroda/godot-agent-plugins | `gdscript` (Architektur, Signale, Muster, Code-Review), **`godot-testing` mit `godot-visual-test`**: Ein Skript steuert das Spiel per Tastatur nach Frame, macht Screenshots bei festen Frames und vergleicht sie pixelgenau mit freigegebenen Bildern (über `override.cfg`, `project.godot` bleibt unverändert). Außerdem `godot-performance` sowie Video und Trailer. | 4.6+, geprüft mit 4.7.2 | 0 ★, Push 31.10.2026, MIT | `npx skills add dannroda/godot-agent-plugins` (ohne `-g` = im Projekt), Ordner von Hand kopieren, oder als Claude-Plugin | + (visual-test ++) | Screenshots brauchen Xvfb (vorhanden) oder gamescope, weil `--headless` nichts zeichnet. Unter Xvfb läuft nur der Compatibility-Renderer. |
| **Game-Dev-Agentic-Skills / gd-agentic-skills** (thedivergentai) | https://github.com/thedivergentai/Game-Dev-Agentic-Skills | 99 Godot-Skills mit dem Hub `godot-master`. Darunter `godot-characterbody-2d`, `godot-tilemap-mastery` (inhaltlich gut: `TileMapLayer`, zerstörbare Kacheln über Custom Data), `godot-input-handling`, `godot-genre-platformer`, `godot-agent-vision` (Screenshots über eine Editor-Brücke). Bringt 982 Beispielskripte mit. | 4.7+ | 917 ★, Push 16.10.2026, LGPL-3.0 | `npx skills add thedivergentai/Game-Dev-Agentic-Skills/skills/<skill>`. Die README nennt `-g` als bevorzugt, ohne `-g` geht es aber im Projekt. **Nie `--all` verwenden.** | + (einzelne Skills) | Sehr groß, das bläht den Kontext auf. Viel „Persona“-Ballast. LGPL bei kopierten Skripten beachten. `godot-testing-patterns` setzt auf GUT statt GdUnit4. |
| **Godot-Skill** (shihabshahrier) | https://github.com/shihabshahrier/Godot-Skill | Ein Skill: GDScript 2.0 mit strengen Typen, Style-Guide, „call down, signal up“, `TileMapLayer` statt `TileMap`. Laut skills.sh am häufigsten installiert (rund 70). | 4.3+ | 3 ★, Push 09.09.2026, keine Lizenz | `npx add-skill …` oder kopieren. Das `install.sh` schreibt **global** in alle Agenten-Ordner. | o | Keine Lizenz. Überschneidet sich mit MindsMaster. Nur von Hand projektlokal zu installieren. |
| **godot** im Repo `Randroids-Dojo/skills` (Nachfolger des installierten `godot:godot`) | https://github.com/Randroids-Dojo/skills | Wie das installierte Plugin: GdUnit4, PlayGodot, Export. Neu ist eine Vorprüfung: Vor PlayGodot prüfen, ob der Fork überhaupt da ist. | 4.x | 46 ★, Push 07.10.2026, MIT | Claude-Marketplace oder `npx skills add … --skill godot`. Die README nennt `-g`. | o | PlayGodot braucht einen eigenen Godot-Fork (gebaut oder heruntergeladen), Python und `pip install playgodot`. |
| **godot-claude-skills** (alexmeckes) | https://github.com/alexmeckes/godot-claude-skills | 5 Skills (Code-Gen, Szenen-Design, Shader, Live-Edit). Gedacht für ein eigenes MCP mit Editor-Brücke. | 4.x | 50 ★, Push 24.03.2026, MIT | Claude-Marketplace | – | Hängt an einer Editor-Brücke. |
| **cc-godot** (Zate) | https://github.com/Zate/cc-godot | Befehle `/gd:*`, ein Planungs-Agent, ein Skill. Braucht ein MCP. | 4.5.1+ | 20 ★, Push 09.11.2025 | Marketplace | – | Seit einem Jahr nicht gepflegt. |
| **Godot-Skills** (fenixnix) | https://github.com/fenixnix/Godot-Skills | 12 kleine Skills (GDScript-Grammatik, TSCN-Format, Autoload, Pooling), chinesisch | 4.x | 6 ★, Push 15.03.2026, MIT | Marketplace oder kopieren | o | Dünn. Nur das TSCN-Format ist interessant. |
| **godot-superpowers** (Asreonn) | https://github.com/Asreonn/godot-superpowers | 29 Skills, vor allem Umstieg von 3 auf 4 und Erzeugen von GUT-Tests | 4.x | 4 ★, Push 11.10.2026, MIT | Kopieren nach `~/.claude/skills` (**global**) | – | Nutzlos für ein neues 4.7-Projekt. |
| **agent-skills** (jwynia) | https://github.com/jwynia/agent-skills | Unter 112 Skills: `godot-best-practices` und `godot-asset-generator` | n. e. | 180 ★, Push 24.02.2026 | `npx skills add …` | o | `godot-asset-generator` ruft externe KI-Dienste für Bilder auf. |
| **Godot Clarity** (AKDworks) | npm `godot-clarity` | Agent-Skill mit Evals, Doku-Links fest auf `/en/4.7/` | 4.7 | **Repo nicht mehr erreichbar (404)**, nur npm `0.1.0-rc.7` vom 23.07.2026 | `npx godot-clarity@next init --ai claude` | – | Quelle verschwunden. Nicht nachprüfbar. |
| **majiayu000/claude-skill-registry** | über openskillindex.com | Ein automatisch aus der Doku erzeugter Godot-Skill | n. e. | n. e. | n. e. | – | Automatisch erzeugt, nicht geprüft. |

### Werkzeuge ohne Editor (CLI und MCP)

| Name | URL | Was er kann | Godot | Pflege | Installation | Passung | Risiken |
|---|---|---|---|---|---|---|---|
| **gda / gda-mcp** (aigengame) | https://github.com/aigengame/godot-agent | CLI, Agent-Skill und MCP in einem Paket. **Headless:** Szenen, Nodes, Skripte, Ressourcen und `project.godot` bearbeiten; `script validate` (Kompilierprüfung), `scene validate`/`preflight` (Szene headless starten, `_ready` ausführen, Fehler melden); `script run` (beliebiges GDScript headless ausführen); `project add-input-action` mit `--joy-button`, `--joy-axis`, `--device`. **Live** (über einen Daemon, 4.6+): Laufzeit-Baum lesen, Eigenschaften lesen und setzen, Eingaben senden (Taste, Maus, Aktion, Sequenz über mehrere Frames), `screen capture`/`frames` (PNG), Fehler, Log, Performance. Ausgabe als strukturiertes JSON. | Headless 4.4+, Live 4.6+ | 55 ★, Push 01.11.2026, MIT, PyPI 0.24.2 vom 28.10.2026 | Im Projekt: `uv add --dev gda` (Extra `gda[mcp]` für den MCP). Die README empfiehlt `uv tool install` (**global**), das ist aber nicht nötig. **Python 3.13+**: `requires-python` in `pyproject.toml` müsste von `>=3.12` auf `>=3.13` steigen (die `.venv` hat schon 3.13). | ++ | Setzt keine `TileMapLayer`-Zellen (geht nur über `script run` mit eigenem Skript). Gamepad-Eingabe im laufenden Spiel ist nur als Aktion dokumentiert, Joypad-Events pro Gerät nicht. Der Daemon trägt beim Start ein Autoload für ein Test-Gerüst in `project.godot` ein (`daemon install`/`uninstall`). Screenshots brauchen eine Fenster-Sitzung (unter Xvfb möglich). Junges Projekt mit schnellen Versionssprüngen. |
| **godot-mcp** (Vollkorn-Games), ein Fork des installierten Coding-Solo | https://github.com/Vollkorn-Games/godot-mcp | 75 Tools, alles headless über `godot --headless --script`: Szenen, Nodes, Signale, Skripte, **`create_tileset`, `set_cells`, `get_tile_data`, `set_custom_tile_data`**, Animation. Interaktiv: Eingaben, **`send_joypad_button`/`send_joypad_motion`**, `game_screenshot`, `run_and_capture`, `capture_screenshot` (Szene statisch rendern), `pause_game`, `wait_for_signal`, `execute_script`. Tools lassen sich filtern (`MCP_TOOLSETS`, `MCP_EXCLUDE_TOOLS`, `MCP_READ_ONLY`). 184 Tests gegen echtes Godot. | 4.x (4.5+ für Laufzeitfehler) | 8 ★, Push 09.08.2026, MIT | **Kein npm-Paket.** Klonen und bauen mit pnpm. Die README nennt `npm install -g pnpm` (**global**); projektlokal geht es über `corepack` oder `npx pnpm` in einem Ordner im Projekt. | ++ (schließt die TileMapLayer-Lücke) | Wenige Nutzer. Hängt beim interaktiven Lauf ein Autoload ein, das auf TCP-Port 9876 lauscht. `run_tests` nutzt GUT statt GdUnit4. `search_assets`/`install_asset` rufen die Asset-Library im Netz auf, deshalb mit `MCP_EXCLUDE_TOOLS` ausschließen. |
| **godot-mcp** (Coding-Solo), **installiert** | https://github.com/Coding-Solo/godot-mcp | Editor starten, Spiel starten und stoppen, Debug-Ausgabe, einfache Szenen und Nodes, Sprite laden, UIDs | 4.x | 6461 ★, Push 16.04.2026, npm 0.1.1 vom 03.02.2026, MIT | `npx -y @coding-solo/godot-mcp` (schon eingerichtet) | o | Keine Tilemap-Zellen, keine Eingaben, keine Screenshots. Wird kaum noch weiterentwickelt. |
| **minimal-godot-mcp** (ryanmazzolini) | https://github.com/ryanmazzolini/minimal-godot-mcp | GDScript-Fehler über den LSP von Godot, Konsole des Spiels über DAP | 3.2+ und 4.x | npm 0.1.7 vom 31.10.2026 | `npx -y @ryanmazzolini/minimal-godot-mcp` | o | Der LSP läuft nur bei **offenem Editor**. Für reine Prüfungen reichen `gdlint` und `gda script validate`. |
| **godot-docs-mcp** (nuskey8) | https://github.com/nuskey8/godot-docs-mcp | Volltextsuche in docs.godotengine.org | „stable“ | 25 ★, Push 02.10.2025 | `npx` | o | Ruft die Doku-Seite im Netz auf. Kein Versionsbezug zu 4.7.2. Ein Jahr alt. |
| **godot-docs-mcp** (james2doyle) | https://github.com/james2doyle/godot-docs-mcp | Doku suchen und Seiten holen | bis 4.6 | 26 ★, **nicht mehr gepflegt**, der öffentliche Server ist abgeschaltet | Selbst auf Cloudflare betreiben | – | Externer Dienst. Kein 4.7. |
| **godot-mcp-docs** (Nihilantropy) | https://github.com/Nihilantropy/godot-mcp-docs | Packt die gesamte Doku in einen Docker-Container | fest eingebaut | 74 ★, Push 25.07.2025 | Docker | – | Braucht einen Container. Veraltet. |
| **Godot selbst**: `--doctool`, `--write-movie`, `--headless --script` | https://docs.godotengine.org/en/4.7/tutorials/editor/command_line_tutorial.html | Klassenreferenz für genau 4.7.2 als XML, Einzelbilder bei fester FPS, eigene Werkzeug-Skripte ohne Editor | 4.7.2 (installiert) | – | Nichts zu installieren | ++ | Keine. Nur ein kleiner eigener Skill ist nötig, damit Agenten das auch nutzen. |
| **GdUnit4** | https://github.com/godot-gdunit-labs/gdUnit4 | Test-Framework in GDScript, Kommandozeilen-Werkzeug für CI, Scene-Runner mit Maus, Tastatur, Touch und Input-Aktionen, JUnit-Bericht | v6.2.x: 4.5 bis 4.7.1; master (v7): 4.7.x und 4.8 | 1287 ★, Push 01.11.2026, MIT | Addon nach `godot-project/addons/gdUnit4` | ++ | Ob 4.7.2 offiziell unterstützt wird, vor der Installation prüfen (laut Tabelle nur 4.7.1 bzw. master). |
| **PlayGodot** (Randroids-Dojo) | https://github.com/Randroids-Dojo/PlayGodot | „Playwright für Godot“: Python-Tests, Screenshots, Bildvergleich, Eingaben | **nur eigener Fork** | 40 ★, Push 24.02.2026 | `pip install playgodot` und Fork bauen | – | Nicht das offizielle 4.7.2. Ein Fork des Engines wäre ein großer Eingriff. |

### Editor-Brücken (Editor muss offen sein)

| Name | URL | Was er kann | Godot | Pflege | Installation | Passung | Risiken |
|---|---|---|---|---|---|---|---|
| **godot-mcp** (satelliteoflove) | https://github.com/satelliteoflove/godot-mcp | Fachlich der stärkste: Spielzeit einfrieren und schrittweise weiterlaufen lassen (auch „bis Bedingung erfüllt“), Laufzeit-Zustand als JSON, **Gamepad-Knöpfe und Sticks**, `godot_tilemap_edit`, Doku passend zur Editor-Version, Screenshots von Spiel und Editor, `godot_exec` im laufenden Spiel | 4.5+ | 183 ★, Push 02.10.2026, npm 4.1.11, MIT | `npx -y @satelliteoflove/godot-mcp`, das Addon per `--install-addon` ins Projekt | o | **Braucht den offenen Editor mit Addon** (WebSocket auf 127.0.0.1:6550). Pro Editor nur ein Client, Subagents müssen warten. |
| **Godot MCP / Godlink** (tomyud1) | https://github.com/tomyud1/godot-mcp | 69 Tools im Editor, Undo/Redo, Visualisierung des Projekts | 4.4+ | 448 ★, Push 17.10.2026, npm `godot-mcp-server` 0.6.1 | Asset Store und npx | – | Editor nötig. |
| **Godot-MCP** (yanhuifair) | https://github.com/yanhuifair/Godot-MCP | 386 Tools. Liest und schreibt `.tscn`/`.tres` auch ohne Godot. Live-Editor, Spiel einfrieren, Schritte, Screenshot, Eingaben | 4.x | 49 ★, Push 23.10.2026, **AGPL-3.0**, npm 1.12.18 | `npx @yanhuifair/godot-mcp --enable-plugin` | o | AGPL. Sehr viele Tools, das kostet Kontext. Für Laufzeit-Tools ist der Editor nötig. |
| **Open-Godot-MCP** (masteryee-labs) | https://github.com/masteryee-labs/Open-Godot-MCP | Deterministisches Playtesting, `godot_tilemap`, Screenshot, DAP und LSP | 4.5+ | 14 ★, Push 23.07.2026, MIT | `pip`/`uv tool` und Addon | o | Editor nötig. README chinesisch. |
| **KeeVeeG/godot-mcp** | https://github.com/KeeVeeG/godot-mcp | Über 300 Tools über WebSocket zum Editor | 4.x | 31 ★, Push 12.07.2026 | Addon und Node | – | Editor nötig. Laut README weitgehend von KI-Modellen geschrieben. |
| **Godot MCP Pro** (youichi-uda) | https://github.com/youichi-uda/godot-mcp-pro | 187 Tools | 4.x | 641 ★, Push 24.09.2026 | Server **nur kostenpflichtig** | – | Kostet Geld. Server nicht offen. |
| **GDAI MCP** (3ddelano) | https://github.com/3ddelano/gdai-mcp-plugin-godot | Editor-Steuerung, Screenshots | 4.x | 103 ★, Push 11.09.2026 | Über die Website gdaimcp.com | – | Keine Lizenz. Bezug über die Website des Anbieters. |
| **Godot Agent Harness** (dannroda) | https://github.com/dannroda/godot-agent | Agenten-Dock im Editor, Playtests mit Belegen, TileMap-Prüfung | 4.7+ | n. e. | Addon und `npx …claude-agent-acp` | – | Ein Agent im Editor, also das Gegenteil des Arbeitswegs hier. |
| **ee0pdt/Godot-MCP**, **bradypp/godot-mcp** | GitHub | Frühe Editor-MCPs | 4.x | Push 03/2025 bzw. 05/2025 | – | – | Veraltet. |

### Pixel-Art und Aseprite

| Name | URL | Was er kann | Godot | Pflege | Installation | Passung | Risiken |
|---|---|---|---|---|---|---|---|
| **Aseprite Wizard** | https://github.com/viniciusgerevini/godot-aseprite-wizard | Importiert `.aseprite` direkt als SpriteFrames, Texture oder Tileset-Atlas, und zwar beim Import. Tags werden zu Animationen, Frame-Dauern werden zu FPS. | 4.x (Asset-Library 9.8.0, getestet mit 4.4) | n. e., MIT | Addon nach `addons/`. Braucht das Aseprite-Programm (unter `/usr/bin/aseprite` vorhanden). | + | Kein Agenten-Skill. Ob der Import bei `godot --headless --import` läuft, ist **nicht geprüft**. Kompatibilität mit 4.7.2 prüfen. |
| **godot-4-aseprite-importers** (nklbdev) | https://github.com/nklbdev/godot-4-aseprite-importers | Ähnliche Importer | 4.x | 101 ★, Push 15.09.2023 | Addon | – | Seit drei Jahren nicht gepflegt. |

Zu Pixel-Art-*Wissen* (Filter `Nearest`, Pixel-Snap, Stretch-Modus) gibt es keinen eigenen Skill. Das deckt `godot-2d` von MindsMaster ab („Pixel-Stil“ steht im Umfang).

## Bewertung nach den gesuchten Fähigkeiten

| Fähigkeit | Bestes Angebot | Ohne Editor? |
|---|---|---|
| GDScript mit durchgehenden Typen | MindsMaster `godot-gdscript`, Godot-Skill (shihabshahrier) | ja (Wissen) |
| `TileMapLayer`/`TileSet` setzen | Vollkorn `set_cells`/`create_tileset`, oder eigenes Skript über `godot --headless --script` bzw. `gda script run` | ja |
| Szenen headless bauen | gda `scene`/`node`, Vollkorn, Coding-Solo (installiert, Grundfunktionen) | ja |
| Tests | GdUnit4 (Teil von `godot:godot`), gda `scene preflight` | ja |
| Spiel steuern und Screenshot | gda Live (`input`, `screen capture`), Vollkorn (`send_*`, `game_screenshot`), dannroda `godot-visual-test` | ja, mit Xvfb |
| Mehrere Eingabegeräte | Vollkorn `send_joypad_*`, satelliteoflove `godot_input` (Editor); Wissen bei MindsMaster `godot-input` | teilweise |
| Aseprite | Aseprite Wizard (Addon), sonst die Aseprite-Kommandozeile `aseprite -b --sheet … --data …` | offen |
| Doku für 4.7.2 | `godot --doctool` (lokal, genau die Version); sonst satelliteoflove `godot_docs` (Editor nötig) | ja |

## Empfehlung

Wie installiert werden soll, entscheidet der Mensch. Hier die Optionen.

### A (empfohlen): schlanker, headless Werkzeugkasten

1. **MindsMaster `godot-skills`** als Claude-Plugin mit `--scope project`. Das ist das Godot-Wissen, geprüft gegen 4.7.2.
2. **`gda`** im Projekt mit `uv add --dev "gda[mcp]"`. Damit können Agenten Szenen headless bauen und prüfen, das Spiel steuern und Screenshots machen. Vorher muss `requires-python` auf `>=3.13` gesetzt werden.
3. **`godot-visual-test`** von dannroda als Skill nach `.agents/skills/` kopieren, für Screenshot-Vergleiche unter `xvfb-run`.
4. **GdUnit4** als Addon für Unit-Tests. Den Teil zu GdUnit4 aus `godot:godot` weiter nutzen, PlayGodot ignorieren.
5. Einen **eigenen kleinen Skill `godot-werkzeuge`** schreiben (Folge-Ticket). Er enthält:
   - ein Headless-Skript, das `TileMapLayer`-Zellen setzt und die Szene speichert,
   - einen Hinweis auf `godot --doctool` für die Doku zu 4.7.2,
   - Screenshots über `--write-movie`.
6. Den Coding-Solo-MCP vorerst behalten oder abschalten. gda deckt seine Funktionen ab, deshalb wird er überflüssig.

- **Vorteile:** Alles läuft ohne Editor und projektlokal. Es gibt keine externen Dienste im Spiel. Der Kontext bleibt klein (16 Skills, laut Autor zusammen rund 3400 Zeichen Beschreibung). gda wird aktiv gepflegt und liefert JSON, das ein Agent gut auswerten kann.
- **Nachteile:** `TileMapLayer` braucht ein eigenes Skript. gda ist jung, und die Versionen ändern sich oft. Das Python-Minimum steigt auf 3.13. MindsMaster hat erst 2 Sterne, die Qualität stützt sich nur auf die eigenen Evals des Autors.

### B: Vollkorn-MCP statt Coding-Solo, dazu MindsMaster

Den installierten Coding-Solo-MCP durch seinen Fork von Vollkorn ersetzen. Den Fork in einen Werkzeug-Ordner im Projekt klonen und dort bauen, `corepack`/`npx pnpm` verwenden statt `npm -g`. Die Tools `search_assets` und `install_asset` mit `MCP_EXCLUDE_TOOLS` ausschließen.

- **Vorteile:** Ein einziger MCP schließt die Lücke bei `TileMapLayer` sofort und kann Gamepad-Eingaben senden und Screenshots machen, alles headless. Die Bedienung ist vertraut, weil die Tool-Namen von Coding-Solo bleiben.
- **Nachteile:** Nur 8 Sterne und kein npm-Paket, Updates gehen von Hand. Der interaktive Lauf öffnet TCP-Port 9876 über ein eingehängtes Autoload. Die Tests laufen mit GUT statt GdUnit4.

### C: Editor-Brücke `satelliteoflove/godot-mcp`, dazu MindsMaster

- **Vorteile:** Das stärkste Testen zur Laufzeit: Zeit einfrieren und in Schritten weiterlaufen lassen, Zustand als JSON, Gamepad mit Stick-Stärke. `TileMapLayer` lässt sich bearbeiten. Die Doku passt zur Editor-Version.
- **Nachteile:** Der Editor muss offen sein, mit Addon. Das bricht die Regel „Agenten öffnen den Editor nicht“, außer der Mensch hält ihn selbst offen. Pro Editor kann nur ein Agent gleichzeitig arbeiten.

### D: nur Wissen, keine neuen Werkzeuge

Nur MindsMaster installieren und alles andere (Tilemap, Screenshots, Doku) als eigene Skripte bauen.

- **Vorteile:** Kaum fremder Code, maximale Kontrolle.
- **Nachteile:** Spiel steuern und Screenshots müssten selbst gebaut werden. Das wäre ein schwächerer Nachbau dessen, was gda schon fertig kann.

### Nicht empfohlen

- PlayGodot (braucht einen Fork)
- kostenpflichtige oder nicht offene MCPs (Godot MCP Pro, GDAI)
- Doku-MCPs mit externem Dienst (nuskey8, james2doyle)
- die Komplett-Installation von Game-Dev-Agentic-Skills
- Godot Clarity (Quelle verschwunden)
- veraltete Pakete (cc-godot, ee0pdt, bradypp, nklbdev)

## Lücken, die nach Option A offen bleiben

1. **`TileMapLayer` ohne Editor:** Kein headless Werkzeug aus A setzt Zellen. Lösung: ein eigenes GDScript-Werkzeug (`TileSet` laden, `set_cell(coords, source_id, atlas_coords)`, Szene mit `PackedScene.pack()` und `ResourceSaver.save()` speichern). Alternativ das Tool `set_cells` aus Option B übernehmen.
2. **Mehrere Gamepads gleichzeitig ansteuern:** gda dokumentiert keine Joypad-Events mit Geräte-Nummer im laufenden Spiel. Das muss getestet werden, oder Tests im Spiel erzeugen `InputEventJoypadButton` mit `device` selbst, zum Beispiel über GdUnit4 oder `gda script run`.
3. **Aseprite headless:** Ob Aseprite Wizard bei `godot --headless --import` importiert, ist nicht geprüft. Sonst gibt es den Umweg über die Aseprite-Kommandozeile: Sprite-Sheet und JSON exportieren, daraus per Skript SpriteFrames bauen.
4. **Unterstützung von 4.7.2 bei GdUnit4:** Laut Kompatibilitätstabelle gilt v6.2.x bis 4.7.1, master (v7) gilt für 4.7.x. Vor der Installation prüfen, welche Version passt.
5. **Doku für 4.7:** Es gibt keinen guten Skill dafür. Ein Skill, der auf das Ergebnis von `godot --doctool` verweist, schließt die Lücke offline.
6. **Screenshots ohne GPU:** Unter Xvfb läuft nur der Compatibility-Renderer. Für ein 2D-Pixel-Spiel ist das unkritisch, wenn das Projekt ohnehin mit `gl_compatibility` läuft. Das sollte man gleich mit entscheiden.

## Quellen

Alle README-Dateien unter den oben genannten GitHub-URLs (gelesen am 01.11.2026). Zusätzlich:

- `SKILL.md` von `godot-tilemap-mastery` (thedivergentai), `godot-visual-test` (dannroda) und `plugins/godot` (Randroids-Dojo/skills)
- npm-Registry und PyPI für Versionen und Datumsangaben
- https://www.skills.sh/shihabshahrier/godot-skill/godot
- https://ziva.sh/blogs/godot-ai-skills
- https://www.summerengine.com/de/blog/godot-mcp-servers-guide
