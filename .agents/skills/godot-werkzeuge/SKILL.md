---
name: godot-werkzeuge
description: Wie Agenten in diesem Projekt ohne Editor mit Godot 4.7.2 arbeiten - Szenen bauen und prüfen, TileMapLayer-Zellen setzen, Spiel steuern, Screenshots machen, GdUnit4-Tests (auch mit mehreren Gamepads) laufen lassen, Klassenreferenz nachschlagen. Nutzen, bevor du Godot-Code baust, testest oder dir das Ergebnis ansehen willst.
---

# Godot-Werkzeuge für Agenten

Alles läuft **ohne Editor**. Den Editor öffnet nur der Mensch. Alle Befehle aus dem Repo-Hauptverzeichnis.

| Aufgabe | Werkzeug |
|---|---|
| Godot-Wissen (Muster, API, Fallstricke) | Plugin `godot-skills` (MindsMaster), lädt sich über `.claude/settings.json` |
| Szenen, Nodes, Skripte bearbeiten und prüfen, Spiel steuern, Screenshots | `uv run gda …` |
| `TileMapLayer`-Zellen setzen | `zellen_setzen.gd` in diesem Ordner |
| Unit- und Szenentests, Gamepads mit Geräte-Nummer | GdUnit4 v6.2.3 in `godot-project/addons/gdUnit4/` |
| Screenshot-Vergleich mit freigegebenen Bildern | Skill `godot-visual-test` |
| Klassenreferenz genau für 4.7.2 | `.godot-doku/` |

## gda

`GDA_GODOT=godot` ist in `.claude/settings.json` gesetzt. Immer `--project godot-project` mitgeben. Die vollständige, zur installierten Version passende Anleitung: `uv run gda skill`. Befehlsübersicht als JSON: `uv run gda schema`.

Ohne Editor, ohne Fenster:

```sh
uv run gda --json script validate --project godot-project <res://pfad.gd>
uv run gda --json scene preflight --project godot-project <res://szene.tscn>
```

**Live-Test mit Screenshot** (braucht Xvfb; der Daemon trägt ein Autoload in `project.godot` ein). Immer in **einem** `xvfb-run`-Aufruf starten und am Ende **aufräumen**:

```sh
xvfb-run -a bash -c '
  uv run gda daemon start --windowed --project godot-project --scene res://<szene>.tscn
  uv run gda daemon wait-ready --project godot-project
  uv run gda input action springen --project godot-project      # Beispiel
  uv run gda screen capture -o <scratchpad>/bild.png --project godot-project
  uv run gda daemon stop --project godot-project
  uv run gda daemon uninstall --project godot-project'
```

Danach muss `git diff godot-project/project.godot` frei von `GdaHarness`/`[autoload]`-Resten sein. Das Bild mit dem Read-Werkzeug ansehen. Unter Xvfb läuft nur der Renderer Compatibility; das Projekt ist darauf eingestellt.

**Grenze:** gda sendet Tasten, Maus und Aktionen, aber **keine Gamepad-Ereignisse mit Geräte-Nummer**. Für „Gamepad 3 drückt Springen“ einen GdUnit4-Test schreiben (unten).

## TileMapLayer-Zellen setzen

Godot speichert Zellen als Byte-Block in der `.tscn`; von Hand oder über MCP lassen sie sich nicht bearbeiten. Stattdessen:

```sh
cd godot-project && godot --headless --path . \
  --script ../.agents/skills/godot-werkzeuge/zellen_setzen.gd -- \
  --szene res://level/palermo/palermo.tscn --ebene Gelaende --zellen <scratchpad>/zellen.json
```

Aufbau von `zellen.json` steht oben im Skript. Reihenfolge: `alles_loeschen`, `rechtecke`, `setzen`, zuletzt `loeschen` (schneidet Löcher). Das Ergebnis mit einem Screenshot prüfen. Ist die Szene im Editor offen, muss der Mensch sie neu laden.

## GdUnit4

```sh
cd godot-project && GODOT_BIN=$(which godot) xvfb-run -a ./addons/gdUnit4/runtest.sh -a res://<ordner>
```

Exit-Code 0 = grün, 100 = Fehler, 101 = Warnungen. `xvfb-run` ist nötig, sonst kommen keine Eingaben an. Berichte landen in `godot-project/reports/` (ignoriert). Nach neuen `class_name`-Skripten vorher einmal `godot --headless --path godot-project --import`.

Gamepad mit Geräte-Nummer:

```gdscript
extends GdUnitTestSuite


func test_gamepad_3_springt() -> void:
	var ereignis := InputEventJoypadButton.new()
	ereignis.device = 2  # drittes Gamepad
	ereignis.button_index = JOY_BUTTON_A
	ereignis.pressed = true
	Input.parse_input_event(ereignis)
	await get_tree().process_frame
	# hier prüfen, dass genau der Ritter von Gerät 2 springt
```

Achsen genauso mit `InputEventJoypadMotion` (`device`, `axis`, `axis_value`).

## Klassenreferenz

Einmal pro Rechner bzw. nach einem Godot-Update erzeugen:

```sh
mkdir -p .godot-doku && godot --headless --doctool .godot-doku
```

Danach z. B. `.godot-doku/doc/classes/TileMapLayer.xml` lesen oder mit `grep` suchen; GDScript-Eigenheiten in `.godot-doku/modules/gdscript/doc_classes/@GDScript.xml`. **Achtung:** `--doctool` löscht vorher `doc/classes` im Zielordner. Nie ohne den Pfad `.godot-doku` aufrufen.

## Neben dem offenen Editor

Der Mensch hat den Editor womöglich offen. Er hält Szenen und `project.godot` im Speicher.

- Bevor du eine Szene oder `project.godot` ohne Editor änderst, sag dem Menschen, welche Datei; danach soll er sie im Editor neu laden (Godot fragt nach).
- Den gda-Daemon nur kurz laufen lassen und immer `gda daemon uninstall` ausführen.

## Danach

```sh
uv run gdformat godot-project
uv run gdlint godot-project
.agents/skills/godot-werkzeuge/typen_pruefen.sh
```

Der Ordner `addons/` ist überall ausgenommen. `typen_pruefen.sh` ist nötig, weil fehlende Typen in `project.godot` nur eine Warnung sind (sonst laufen die Headless-Befehle von gda nicht, deren eigene Skripte untypisiert sind) und Godot headless keine Warnungen ausgibt. Auch `gda script validate` meldet fehlende Typen nicht.
