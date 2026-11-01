# Eigene Kollision statt Godot-Physik für Figuren und Gelände

Ritter, Gegner und alles, was auf dem Gelände landet (fallende Blöcke, Leichen, Fässer, Pfeile), bewegen sich mit eigener Rechteck-Kollision (AABB) gegen das Block-Raster: erst X, dann Y. Die `TileMapLayer` zeigt die Blöcke nur an und hat keine Kollision; es gibt kein `CharacterBody2D`/`move_and_slide` und kein `RigidBody2D` gegen das Gelände. Grund: Das Spielgefühl hat oberste Priorität, Broforce selbst arbeitet so, und das Raster bleibt die einzige Wahrheit. Ein zerstörter Block ist sofort durchlässig, ohne Neubau von Physikformen, und nichts hängt an Kachel-Nähten. Nur Angriffe zwischen Figuren laufen über `Area2D`.

## Considered Options

- `CharacterBody2D` + `move_and_slide` gegen die TileMapLayer-Kollision: schnellerer Start, aber zwei Datenquellen, Neubau bei jeder Zerstörung und Kampf gegen Floor-Snap und Sicherheitsabstand.
- `RigidBody2D`-Trümmer über eine zusätzliche Kachel-Kollision: echte Physik, aber wieder zwei Datenquellen. Abprallen wird bei Bedarf nachgeahmt.

Details: [Kollision des Ritters](../wayfinder/tickets/11-kollision-des-ritters.md)
