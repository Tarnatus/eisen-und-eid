# Eisen & Eid

Überdrehtes Ritter-Action-Spiel im Stil von Broforce: bis zu vier Ritter kämpfen sich lokal mit Gamepad oder Tastatur durch zerstörbare Level bis zu einem Boss.

- `godot-project/`: das Godot-Spiel (in Arbeit, Prototyp)
- `index.html`: die ursprüngliche Browser-Version, dient als Vorlage
- `docs/wayfinder/map.md`: die Karte mit allen Entscheidungen und offenen Tickets
- `GLOSSARY.md`: die Begriffe des Spiels
- `CLAUDE.md` (= `AGENTS.md`): Code-Regeln

## Was man braucht

| Werkzeug | Version | Wofür |
|---|---|---|
| [Godot](https://godotengine.org/download) | 4.7.2, Standard-Version (nicht .NET) | Editor und Spiel |
| [uv](https://docs.astral.sh/uv/) | aktuell | installiert die Entwicklungswerkzeuge ins Projekt (holt bei Bedarf Python 3.13) |
| Xvfb (`xvfb-run`) | aktuell, z. B. `sudo apt install xvfb` | Tests und Screenshots ohne Bildschirm für Agenten |
| [Claude Code](https://claude.com/claude-code) | aktuell | Agent; optional |

`godot` muss im `PATH` liegen (Agenten rufen es als `godot` auf).

Alles Weitere wird **nur im Projekt** installiert, nichts global.

## Einrichten

Einmal im Repo-Hauptverzeichnis ausführen:

```sh
uv sync
```

Das legt `.venv/` im Repo an und installiert dort `gdtoolkit` (`gdformat`, `gdlint`) und `gda` (Godot-Werkzeug für Agenten) in den Versionen aus `uv.lock`.

GdUnit4 (Tests) liegt fertig in `godot-project/addons/gdUnit4/` und ist eingeschaltet; dafür ist nichts zu tun.

### Für Agenten (Claude Code)

Das meiste findet Claude Code von selbst im Repo: Skills in `.claude/skills/` (Quelle `.agents/skills/`), Einstellungen in `.claude/settings.json`. Von Hand bleibt:

1. **Projekt beim ersten Start vertrauen** und die Frage nach dem Marketplace `godot-claude-code-skills` bzw. dem Plugin `godot-skills` bestätigen. Kommt keine Frage:
   ```sh
   claude plugin marketplace add MindsMaster/godot-claude-code-skills
   claude plugin install godot-skills@godot-claude-code-skills --scope project
   ```
2. **Godot-Klassenreferenz erzeugen** (einmal pro Rechner und nach jedem Godot-Update; landet im ignorierten Ordner `.godot-doku/`):
   ```sh
   mkdir -p .godot-doku && godot --headless --doctool .godot-doku
   ```
3. **Keinen Godot-MCP-Server einrichten.** Wer noch den alten `@coding-solo/godot-mcp` eingetragen hat, entfernt ihn: `claude mcp remove godot`.

Wie Agenten die Werkzeuge benutzen, steht im Skill `godot-werkzeuge`.

## Arbeiten

Projekt im Editor öffnen:

```sh
godot --editor --path godot-project
```

GDScript formatieren und prüfen (nach jeder Änderung):

```sh
uv run gdformat godot-project
uv run gdlint godot-project
.agents/skills/godot-werkzeuge/typen_pruefen.sh
```

Fehlende Typen sind in `project.godot` nur eine Warnung, weil `gda` sonst nicht läuft. `typen_pruefen.sh` macht sie für die Prüfung zum Fehler.

Tests ausführen:

```sh
cd godot-project && GODOT_BIN=$(which godot) xvfb-run -a ./addons/gdUnit4/runtest.sh -a res://
```

**Editor und Agent gleichzeitig:** Agenten ändern Szenen und `project.godot` ohne Editor. Ist die Datei im Editor offen, fragt Godot nach dem Neuladen: dann „Neu laden“ wählen, sonst überschreibt das nächste Speichern die Änderung des Agenten.
