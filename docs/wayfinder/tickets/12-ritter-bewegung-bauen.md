---
title: Ritter-Bewegung bauen
type: task
status: closed
assignee: fjw
blocked_by: [01, 05, 11, 19]
---

## Question

Den echten Ritter mit Bewegung bauen, damit spätere Tickets (Moveset, Palermo, Gegner) auf echtem Code testen können:

- Block-Raster als einzige Wahrheit für das Gelände, `TileMapLayer` nur zur Anzeige (siehe „Kollision des Ritters“).
- Gemeinsamer Bewegungs-Baustein: Kasten (AABB) gegen das Raster, Schwerkraft, erst X, dann Y, Boden/Wand/Decke erkennen. Ritter und Gegner sollen ihn später nutzen. Ob der Ritter davon erbt oder ihn als Kind-Node hat, wird beim Bau mit dem Menschen entschieden.
- Ritter-Steuerung mit den Broforce-Werten aus „Bewegung zum Anfassen“: Laufen, Sprint, Sprung mit Halten, Jump Buffer, Coyote-Zeit, Wandrutschen, Wand-Hüpfer, Kanten-Flip, Plattformen durchfallen.
- Eingabe über die Aktionen aus `project.godot`, Tastatur und Gamepad. Mehrere Spieler kommen mit „Koop-Regeln für 1–4 Spieler“.
- Eine einfache Testszene mit Gelände zum Ausprobieren.

Vorlage: `prototyp_ritter_bewegung.gd` auf dem Branch `prototype/bewegung`. Fertig, wenn sich der echte Ritter so anfühlt wie der Prototyp mit F1.

## Entscheidungen beim Bau

- **Erben statt Kind-Node** (2026-11-02): Basisklasse `Koerper extends Node2D` mit Kasten, Geschwindigkeit, Boden/Wand/Decke und `bewegen()`; `Ritter extends Koerper` setzt nur die Steuerung drauf. Grund: kaum Umbau gegenüber dem Prototyp, der Ritter bewegt seine eigene Position, passt zu „call down, signal up“.
- **Gelände aus der TileMapLayer** (2026-11-02): Node `Gelaende` mit `TileMapLayer` als Kind liest beim Start alle gemalten Zellen ins Raster; die Art (leer, fest, Plattform) steht als Custom Data `art` am Tile. Kein Physics Layer. Platzhalter-TileSet mit zwei Kacheln. Grund: Palermo wird in der `TileMapLayer` gemalt, der Weg steht damit ab jetzt.

## Resolution

Gebaut und vom Menschen abgenommen, 2026-11-02: Der echte Ritter fühlt sich an wie der Prototyp mit F1.

- `gelaende/gelaende.gd` + `gelaende.tscn` (`class_name Gelaende`): Block-Raster, liest beim Start die `TileMapLayer` „Bloecke“ ein; Art (`LEER`, `FEST`, `PLATTFORM`) als Custom Data `art` am Tile. Über dem Raster leer, links/rechts/unten fest.
- `gelaende/bloecke.tres` + `platzhalter_bloecke.png`: TileSet mit zwei Platzhalter-Kacheln (Atlas 0:0 fest, 1:0 Plattform).
- `gemeinsam/koerper.gd` (`class_name Koerper extends Node2D`): Kasten, `geschwindigkeit`, `richtung`, `auf_boden`, `wand_seite`, `an_decke`, `schwerkraft_anwenden()`, `bewegen()`, `durch_plattformen_fallen()`, `steht_nur_auf_plattform()`, `kante_erreicht()`. Gelände über `@export var gelaende`.
- `ritter/ritter.gd` + `ritter.tscn` (`class_name Ritter extends Koerper`): Steuerung mit den Broforce-Werten, Platzhalter-Zeichnung nach Zustand.
- `ritter/testraum/`: Testraum (Bereiche A–G wie im Prototyp), Startszene des Projekts. Für `Gelaende` sind „Editierbare Kinder“ an.
- Abweichung vom Prototyp: Der Kasten prüft alle Zellen auf dem Weg, nicht nur die Ziel-Zelle; schnelle Körper rutschen nicht mehr durch Wände und Decken.
- Tests (GdUnit4): `gemeinsam/koerper_test.gd`, `ritter/ritter_test.gd`, 8 grün.
- Noch offen für spätere Tickets: Eingabe ist global (mehrere Spieler: „Koop bauen“), kein Sprite („Platzhalter-Grafiken zum Anschauen“), Raster kennt noch keine Härte und keine Zerstörung („Kampf des Ritters bauen“).
