---
title: Wie baut man zerstörbares Block-Gelände in Godot 4.7?
type: research
status: closed
assignee:
blocked_by: []
---

## Question

Welche Ansätze gibt es für Broforce-artiges, blockweise zerstörbares Gelände in Godot 4.7 (TileMapLayer mit Laufzeit-Änderung, eigene Grid-Lösung, Physik-Trümmer)? Wie verhalten sich Kollision, Performance, Einsturz nicht gestützter Blöcke und Trümmer/Partikel? Was empfehlen Erfahrungsberichte?

## Resolution

Details: [research/03-zerstoerbares-gelaende.md](../research/03-zerstoerbares-gelaende.md)

TileMapLayer für Darstellung und Kollision, daneben ein eigenes Raster (Material, Lebenspunkte) als einzige Wahrheit. Kleinere `physics_quadrant_size` für die zerstörbare Ebene. Einsturz als begrenzte Suche im nächsten Physik-Tick (Eigenbau). Trümmer überwiegend Partikel plus wenige RigidBody2D. Plan B bei schlechtem Kantengefühl: eigene AABB-Kollision gegen das Raster. Broforce-Blockgröße 16 px ist nicht belegt. Die offene Frage im Dokument zu Online-Vorbereitung entfällt: Online ist out of scope.
