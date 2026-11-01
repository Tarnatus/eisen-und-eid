---
title: Kollision des Ritters
type: grilling
status: closed
assignee: fjw
blocked_by: []
---

## Question

Bewegt sich der Ritter mit eigener Rechteck-Kollision (AABB) gegen das Block-Raster, wie Broforce selbst, oder mit `CharacterBody2D`/`move_and_slide` gegen die TileMapLayer-Kollision? Die Recherchen empfehlen unterschiedlich: Wie fühlt sich Broforce-Bewegung an? → eigene AABB; Wie baut man zerstörbares Block-Gelände in Godot 4.7? → TileMapLayer-Kollision mit AABB als Plan B.

## Resolution

Entschieden im Gespräch (Grilling), 2026-11-01. ADR: [Eigene Kollision statt Godot-Physik](../../adr/0001-eigene-kollision-statt-godot-physik.md).

- **Gelände:** Das eigene Block-Raster ist die einzige Wahrheit für Kollision, Zerstörung und Material. Die `TileMapLayer` zeigt nur an, ohne Physics Layer.
- **Bewegung:** Ein gemeinsamer Baustein bewegt einen Kasten (AABB) gegen das Raster: Schwerkraft, erst X, dann Y, Boden/Wand/Decke erkennen. Ritter und Gegner nutzen ihn mit eigener Steuerung und eigenen Werten. Erben oder Kind-Node wird beim Bau entschieden.
- **Alles andere auf dem Gelände:** Fallende Blöcke, Leichen, Fässer über denselben Baustein, Pfeile per Zellprüfung. Staub und Splitter sind Partikel ohne Kollision. Kein `RigidBody2D` gegen das Gelände. Ersetzt den Vorschlag aus „Wie baut man zerstörbares Block-Gelände in Godot 4.7?“, fallende Blockgruppen als `CharacterBody2D` zu führen.
- **Körper untereinander:** Ritter und Gegner blockieren sich nicht; nur das Gelände blockiert. Kontaktschaden entscheidet „Moveset im Kampf“.
- **Angriffe:** Hitbox/Hurtbox über `Area2D`, unabhängig von der Bewegung.
- **Plattform-Blöcke:** von Anfang an im Raster. Von unten durchspringen, oben stehen, „unten + Sprung“ lässt fallen. Leitern erst, wenn „Palermo: Aufbau und Gegner“ sie braucht.
