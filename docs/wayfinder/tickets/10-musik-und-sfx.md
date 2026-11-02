---
title: Musik und Soundeffekte
type: grilling
status: closed
assignee: fjw
blocked_by: []
---

## Question

Wie wird der 69-Sekunden-Song (`docs/Eisen und Eid.mp3`) eingesetzt (Schleife, Bosskampf, Format), und woher kommen die Soundeffekte für den Prototyp?

## Resolution

Entschieden im Gespräch, 2026-11-02:

| Thema | Entscheidung |
|---|---|
| Songs | Drei Songs aus `docs/`: **Ritter Krass** (62 s) im Level, **Eisen und Eid** (70 s) im Bosskampf und beim Sieg, **Kleiner Ritter** (46 s) auf Titelbild und Game Over. |
| Schleife | Die Songs haben keine Loop-Punkte und bleiben bis zum Ende laut. Sie laufen als ganzer Song in Schleife mit etwa 1 s Überblenden (`AudioStreamPlaylist` mit Überblendzeit). Loop-Punkte von Hand schneiden nur, falls der Übergang stört. |
| Format | MP3 unverändert, kopiert nach `godot-project/audio/musik/` (`ritter_krass.mp3`, `eisen_und_eid.mp3`, `kleiner_ritter.mp3`). Keine Umwandlung in OGG. |
| Level → Boss | Sobald die Arena sich schließt, bricht Ritter Krass hart ab. Es folgen 1–2 s Stille mit dem Horn als Auftritt, dann setzt Eisen und Eid ein. |
| Song-Moment | Beim letzten Treffer bricht die Musik ab, die Zeitlupe ist still. Mit der Explosion springt Eisen und Eid an eine feste Stelle (den Refrain) und läuft unter dem Siegbild ohne Schleife bis zum Ende. Den Zeitpunkt legt der Mensch beim Anhören fest. |
| Tod | Die Musik läuft beim Tod eines Ritters ungestört weiter; der Tod-Sound reicht. |
| Game Over | Die Musik bricht ab, Kleiner Ritter beginnt mit dem Game-Over-Bild. |
| Busse | `Master`, `Musik`, `Effekte`, damit ein späteres Menü sie getrennt regeln kann. Die Musik wird nie automatisch leiser, auch nicht bei Warnungen des Bosses. |
| Häufige Sounds | Schlag, Block bricht, Treffer usw. mit leicht zufälliger Tonhöhe (`AudioStreamRandomizer`) und einer Obergrenze gleichzeitiger Stimmen (`max_polyphony`), damit vier Spieler kein Lärmbrei werden. |
| Herkunft der Sounds | Grundstock aus freien CC0-Paketen von Kenney (z. B. „Impact Sounds“, „RPG Audio“), Lücken mit dem Browser-Generator jsfxr. Herunterladen macht der Mensch, der Agent wählt aus und baut ein. Herkunft und Lizenz jedes Sounds in `godot-project/audio/QUELLEN.md`. |
| Bau | Neues Ticket „Musik und Sounds einbauen“ nach „Kampf des Ritters bauen“. Sounds der Gegner kommen in „Gegner bauen“, alles Boss-Eigene (Horn-Wechsel, Song-Moment, Sound pro Angriff) in „Kamelhauptmann bauen“. |

Fakten aus der Prüfung: alle drei Songs MP3, 48 kHz Stereo, −15 bis −14 LUFS, keine Stille am Anfang, Ende nach kurzem Ausklang. Das Webspiel erzeugt Musik und Sounds per Oszillator im Code; davon wird nichts übernommen.

