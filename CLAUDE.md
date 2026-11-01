# Eisen & Eid

Godot-4.7.2-Prototyp eines überdrehten Ritter-Action-Spiels im Stil von Broforce. Einrichten und Werkzeuge: `README.md`.

- Karte mit Entscheidungen und Tickets: `docs/wayfinder/map.md`
- Begriffe: `GLOSSARY.md`. Code-Namen folgen den Glossar-Begriffen.

## Code

- **GDScript mit durchgehenden Typen.** `var geschwindigkeit: float`, `func springen() -> void`, `:=` nur bei eindeutigem Typ. Fehlende Typen sind in `project.godot` als Fehler eingestellt.
- **Deutsche Namen** für Klassen, Methoden, Variablen, Signale, Nodes, Dateien und Ordner. Kommentare auf Deutsch. Die Godot-API bleibt natürlich englisch.
- **Umlaute und ß werden überall umgeschrieben:** ä → ae, ö → oe, ü → ue, ß → ss. Beispiel: `zerstoerbarer_block.gd`, `class_name ZerstoerbarerBlock`, `func schaden_nehmen()`.
- **Schreibweise nach Godot-Style-Guide:** Dateien, Ordner, Variablen, Funktionen und Signale in `snake_case`; `class_name` und Nodes in `PascalCase`; Konstanten in `CONSTANT_CASE`.
- Nach jeder Änderung an GDScript: `uv run gdformat godot-project` und `uv run gdlint godot-project`.

## Ordner

Nach Spielinhalt, nicht nach Dateityp: Szene, Skript, Sprites und Sounds eines Dings liegen zusammen.

```
godot-project/
  ritter/                  Spielfigur
  gegner/<gegnertyp>/      z. B. gegner/saebelkaempfer/
  bosse/<boss>/            z. B. bosse/kamelhauptmann/
  level/<level>/           z. B. level/palermo/
  gelaende/                Blöcke, Zerstörung, Trümmer
  ui/                      HUD, Menüs
  audio/                   Musik und globale Soundeffekte
  autoload/                Autoload-Skripte
  gemeinsam/               Geteiltes: Palette, Schriften, Hilfsszenen
```

Ordner werden erst angelegt, wenn etwas hineinkommt.

## Kommunikation zwischen Teilen

- Innerhalb einer Szene: **„call down, signal up“**. Eltern rufen Kinder direkt auf, Kinder melden sich über eigene Signale.
- Wenige Autoloads mit klarer Aufgabe, angelegt erst bei Bedarf:
  - `Ereignisse`: Signal-Bus **nur** für spielweite Ereignisse (z. B. `boss_besiegt`, `ritter_gestorben`, `block_zerstoert`). Was nur eine Szene betrifft, gehört nicht hierher.
  - `Musik`: steuert die Musik.
  - `Mitspieler`: wer mit welchem Eingabegerät mitspielt.

## Git

Git-Schreibvorgänge (commit, push, branch …) macht immer der Mensch.
