---
title: Projektstruktur im Godot-Projekt
type: grilling
status: closed
assignee: fjw
blocked_by: []
---

## Question

Wie ist `godot-project/` aufgebaut: Ordner für Szenen, Skripte und Assets, Namensregeln für Dateien und Nodes, Autoloads, wo liegen Level, Ritter, Gegner, Boss, Audio? Sprache von Code und Kommentaren?

## Resolution

Festgehalten in [`CLAUDE.md`](../../../CLAUDE.md) (Symlink `AGENTS.md`), Einrichtung in [`README.md`](../../../README.md).

- GDScript mit durchgehenden Typen; fehlende Typen sind Fehler (`untyped_declaration=2`), `unsafe_*` sind Warnungen.
- Deutsche Namen für Klassen, Methoden, Variablen, Dateien, Ordner; Kommentare deutsch; Umlaute/ß überall umgeschrieben (ae, oe, ue, ss); Schreibweise nach Godot-Style-Guide.
- Ordner nach Spielinhalt (`ritter/`, `gegner/`, `bosse/`, `level/`, `gelaende/`, `ui/`, `audio/`, `autoload/`, `gemeinsam/`), angelegt erst bei Bedarf.
- Wenige Autoloads, angelegt erst bei Bedarf: `Ereignisse` (nur spielweite Signale), `Musik`, `Mitspieler`; in Szenen „call down, signal up“.
- `gdtoolkit` projektlokal über uv (`pyproject.toml`, `.venv/`), Aufruf `uv run gdformat|gdlint`. Nichts wird global installiert.
