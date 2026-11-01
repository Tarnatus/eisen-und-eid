---
title: Ritter-Bewegung bauen
type: task
status: open
assignee:
blocked_by: [01, 05, 11]
---

## Question

Den echten Ritter mit Bewegung bauen, damit spätere Tickets (Moveset, Palermo, Gegner) auf echtem Code testen können:

- Block-Raster als einzige Wahrheit für das Gelände, `TileMapLayer` nur zur Anzeige (siehe „Kollision des Ritters“).
- Gemeinsamer Bewegungs-Baustein: Kasten (AABB) gegen das Raster, Schwerkraft, erst X, dann Y, Boden/Wand/Decke erkennen. Ritter und Gegner sollen ihn später nutzen. Ob der Ritter davon erbt oder ihn als Kind-Node hat, wird beim Bau mit dem Menschen entschieden.
- Ritter-Steuerung mit den Broforce-Werten aus „Bewegung zum Anfassen“: Laufen, Sprint, Sprung mit Halten, Jump Buffer, Coyote-Zeit, Wandrutschen, Wand-Hüpfer, Kanten-Flip, Plattformen durchfallen.
- Eingabe über die Aktionen aus `project.godot`, Tastatur und Gamepad. Mehrere Spieler kommen mit „Koop-Regeln für 1–4 Spieler“.
- Eine einfache Testszene mit Gelände zum Ausprobieren.

Vorlage: `prototyp_ritter_bewegung.gd` auf dem Branch `prototype/bewegung`. Fertig, wenn sich der echte Ritter so anfühlt wie der Prototyp mit F1.
