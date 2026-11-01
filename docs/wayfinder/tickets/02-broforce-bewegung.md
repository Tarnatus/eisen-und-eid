---
title: Wie fühlt sich Broforce-Bewegung an?
type: research
status: closed
assignee:
blocked_by: []
---

## Question

Wie funktionieren Laufen, Beschleunigen/Bremsen, Sprung (Höhe, variable Sprunghöhe, Coyote Time, Jump Buffer), Wandklettern/Wall-Jump, Schwerkraft, Fallgeschwindigkeit, Leiter/Seil, Kamera (Mehrspieler) und Treffer-Feedback (Screenshake, Hitstop) in Broforce? Welche konkreten Werte oder Faustregeln sind bekannt, und wie baut man das in Godot 4.7 nach (CharacterBody2D vs. eigene Kollision)?

## Resolution

Details: [research/02-broforce-bewegung.md](../research/02-broforce-bewegung.md)

Quellen: Modding-Community (Broforce-Docs, Mod-Quellcode), kein offizielles Postmortem. Werte in Pixeln: Block 16, Figur 12×18, Laufen 110 px/s (Sprint ×1,5), Bodenbremsung fast sofort, in der Luft keine Reibung, Schwerkraft 1100 px/s², Sprunggeschwindigkeit 260 px/s gehalten bis 0,123 s (kurz ≈ 2, voll ≈ 4 Blöcke), Fallen max. 400 px/s, Jump Buffer 0,2 s, Coyote Time geschätzt 0,08 s. Wand: Abrutschen max. 40 px/s, Wandsprung als senkrechter Hüpfer, Flip über Überhang. Kamera: gemeinsam, ca. 454 px breit, kein Zoom im Koop. Screenshake in Stufen, kein Hitstop nachgewiesen. Offen: Leiter-Geschwindigkeit, Kamera-Nachführung. Die Wahl der Kollisionstechnik ist als eigenes Ticket ausgelagert: Kollision des Ritters.
