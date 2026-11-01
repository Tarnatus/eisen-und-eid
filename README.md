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
| [uv](https://docs.astral.sh/uv/) | aktuell | installiert die Entwicklungswerkzeuge ins Projekt |

Alles Weitere wird **nur im Projekt** installiert, nichts global.

## Einrichten

Einmal im Repo-Hauptverzeichnis ausführen:

```sh
uv sync
```

Das legt `.venv/` im Repo an und installiert dort `gdtoolkit` (`gdformat`, `gdlint`) in der Version aus `uv.lock`.

## Arbeiten

Projekt im Editor öffnen:

```sh
godot --editor --path godot-project
```

GDScript formatieren und prüfen (nach jeder Änderung):

```sh
uv run gdformat godot-project
uv run gdlint godot-project
```
