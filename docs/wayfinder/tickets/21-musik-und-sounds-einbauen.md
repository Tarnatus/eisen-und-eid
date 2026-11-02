---
title: Musik und Sounds einbauen
type: task
status: open
assignee:
blocked_by: [10, 13]
---

## Question

Musik und den Grundstock an Soundeffekten nach „Musik und Soundeffekte“ einbauen:

- Audio-Busse `Master`, `Musik`, `Effekte`.
- Autoload `Musik`: Song starten, hart abbrechen, an eine Stelle springen; Schleife mit etwa 1 s Überblenden (`AudioStreamPlaylist`).
- Songs nach `godot-project/audio/musik/` kopieren: Ritter Krass im Level, Kleiner Ritter auf Titelbild und Game Over (sobald es diese Bilder gibt).
- Kenney-Pakete (CC0) herunterladen: macht der Mensch nach Liste des Agenten. Lücken mit jsfxr.
- Sounds für Ritter und Gelände: Schlag, Powerschlag, Schild hält ab, Bumerangaxt (Wurf, Rückkehr), Block bricht je Härte, Ölfass, Tod, Gefangener befreit, Ross, Sprung/Landung nach Bedarf.
- Häufige Sounds mit `AudioStreamRandomizer` (leicht zufällige Tonhöhe) und `max_polyphony`.
- `godot-project/audio/QUELLEN.md` mit Herkunft und Lizenz jedes Sounds.

Abzustimmen: Lautstärke der Busse zueinander, Lautstärke je Sound, Stärke der Tonhöhen-Streuung, Obergrenzen. Fertig, wenn Kampf und Gelände sich mit Ton gut anfühlen; die abgestimmten Werte stehen in der Resolution.
