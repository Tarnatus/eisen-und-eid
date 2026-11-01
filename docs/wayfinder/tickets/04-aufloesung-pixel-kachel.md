---
title: Auflösung, Pixel- und Kachelgröße
type: grilling
status: closed
assignee: fjw
blocked_by: [02, 03]
---

## Question

Welche interne Auflösung, welche Skalierung (Pixel-Perfect, Stretch-Mode), welche Kachelgröße und welche Größe hat ein Ritter in Pixeln? Wie viele Kacheln sieht man auf dem Bildschirm, auch wenn 4 Spieler sich verteilen?

## Resolution

Entschieden im Gespräch (Grilling), 2026-11-01.

- **Block:** 16 × 16 px (wie Broforce, Werte aus „Wie fühlt sich Broforce-Bewegung an?“ gelten 1:1).
- **Ritter:** Kollisionskasten 12 × 18 px, Sprite-Bild 32 × 32 px. Waffe, Schild, Helmbusch dürfen über den Kasten hinausragen; Wucht kommt über das Sprite, nicht über den Kasten.
- **Interne Auflösung:** 480 × 270 → 30 × knapp 17 Blöcke sichtbar. Am nächsten an Broforce (ca. 28 Blöcke breit).
- **Zeichnen:** `window/stretch/mode="viewport"`, `scale_mode="integer"`, `aspect="keep"` (16:9, sonst Balken). Texturfilter `nearest`. Grund für `viewport`: Trümmer, Partikel und Screenshake bleiben auf dem Pixelraster.
- **Vergrößerung:** nur ganzzahlig. 1080p ×4 und 4K ×8 füllen den Schirm; 1440p ×5 mit schmalem Rand; Steam Deck mit viel Rand. Weiche Restskalierung per `SubViewport` erst, falls die Zielplattform es verlangt.
- **Koop-Kamera:** feste Zoomstufe, kein Herauszoomen. Alle sehen dieselben 30 × 17 Blöcke. Festhalten am Bildrand gehört zu „Koop-Regeln für 1–4 Spieler“.
- **Fenster beim Start:** 1440 × 810 (×3).
- **Gegen Flimmern:** Physik-Interpolation an, Kameraposition auf ganze Pixel runden; „Snap 2D Transforms“ und „Snap 2D Vertices“ nicht kombinieren.
- Die Einstellungen in `project.godot` werden im Prototyp „Bewegung zum Anfassen“ gesetzt.
