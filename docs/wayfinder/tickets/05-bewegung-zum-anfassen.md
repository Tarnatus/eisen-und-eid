---
title: Bewegung zum Anfassen
type: prototype
status: closed
assignee: fjw
blocked_by: [01, 04, 11]
---

## Question

Wie muss sich der Ritter bewegen, damit es sich gut anfühlt? Ein Ritter in einem Testraum mit Blöcken, Wänden und Plattformen; Werte werden gemeinsam eingestellt, bis das Spielgefühl sitzt.

## Assets

- Prototyp (Wegwerf-Code): `godot-project/ritter/prototyp_bewegung/`. Start: `godot --path godot-project res://ritter/prototyp_bewegung/prototyp_bewegung.tscn` oder im Editor die Szene mit F6.
- Prototyp-Branch: `prototype/bewegung` (wird nie gemergt).

## Resolution

Entschieden im Prototyp, 2026-11-01: Der Wertesatz **Broforce** (F1) fühlt sich richtig an und wird unverändert übernommen. „Schwerer Ritter“ und „Leicht und schnell“ kamen dem Ziel weniger nahe.

| Bereich | Wert |
|---|---|
| Laufen | Tempo 110 px/s, Anschub 25 px/s, Beschleunigung 220 px/s² (+286 unter 50 px/s), Sprint × 1,5 |
| Bremsen | Boden 20/s (v *= 1 − 20·dt), Luft 0 |
| Sprung | Schwerkraft 1100 px/s², Steigen 260 px/s konstant für bis zu 0,123 s Halten, max. Fall 400 px/s |
| Sprung-Hilfen | Jump Buffer 0,2 s, Coyote-Zeit 0,08 s, Abstand zwischen Sprüngen 0,08 s |
| Wand | Rutschen max. 40 px/s, Klebezeit 0,2 s, Wand-Hüpfer 260 px/s (ohne Halten), Abstand 0,2 s |
| Kanten-Flip | an, 220 px/s hoch, 100 px/s seitlich, 0,18 s |
| Plattform | „unten + Sprung“ fällt 0,15 s lang durch |

Die Bewegungslogik zum Übernehmen steht in `prototyp_ritter_bewegung.gd` auf dem Prototyp-Branch (Kasten 12 × 18 gegen das Raster, erst X, dann Y, Boden/Wand/Decke erkennen).
