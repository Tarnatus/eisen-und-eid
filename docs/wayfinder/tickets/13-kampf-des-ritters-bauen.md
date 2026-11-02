---
title: Kampf des Ritters bauen
type: task
status: open
assignee: fjw
blocked_by: [06, 12]
---

## Question

Den Kampf nach „Moveset im Kampf“ in den echten Ritter bauen und die Werte gemeinsam im Spiel abstimmen:

- Schlag (antippen) und Powerschlag (halten, loslassen) nach vorn, oben und in der Luft nach unten; Angreifen ohne die Bewegung anzuhalten.
- Schild halten: vorn bzw. mit „oben“ nach oben, am Boden und in der Luft, langsames Laufen, kein Angriff.
- Bumerangaxt mit 3 Ladungen.
- Blöcke mit Härte weich, hart, unzerstörbar; was welche Härte bricht, steht in „Moveset im Kampf“.
- 1 Treffer = tot (vorerst einfach Neustart am Startpunkt; Leben, Ross und Wiedereinstieg kommen mit „Koop bauen“).
- Powerschlag stößt auch Mitspieler zurück, ohne Schaden (siehe „Koop-Regeln für 1–4 Spieler“).
- Treffer-Effekte: kurzes Einfrieren, Wackeln.
- Neue Eingabe-Aktionen `angreifen`, `schild`, `bumerangaxt` in `project.godot`; Sprinten von Gamepad X entfernen. Gamepad-Belegung siehe „Moveset im Kampf“, Tastaturbelegung (linke Hälfte: F Schlag, G Schild, H Bumerangaxt) siehe „Koop-Regeln für 1–4 Spieler“.
- Testszene erweitern: Testpuppen, die zurückschlagen bzw. Geschosse werfen, und Blöcke aller drei Härtestufen.

Abzustimmen: Ladezeit des Powerschlags, Reichweiten, Wurfbahn der Bumerangaxt, Schild-Tempo, Stärke der Treffer-Effekte. Fertig, wenn sich der Kampf gut anfühlt; die abgestimmten Werte stehen in der Resolution.

## Entscheidungen beim Bau

Mit dem Menschen abgestimmt, 2026-11-02:

1. **Treffer-Schnittstelle:** Baustein `Trefferzone` (`Area2D`) als Kind an allem, was getroffen werden kann. Angriffe rufen `trefferzone.treffen(treffer)`, die Trefferzone meldet `getroffen(treffer)` nach oben. `Treffer` ist eine kleine Datenklasse (Art, Richtung, Rückstoß, Verursacher).
2. **Kampf-Code:** Schlag, Powerschlag und Schild in `ritter.gd`; die Bumerangaxt als eigene Szene `ritter/bumerangaxt/`.
3. **Treffer finden:** Schläge fragen im Moment des Schlags einmal per `intersect_shape` ab; die Bumerangaxt ist ein `Area2D` mit `area_entered` und merkt sich, wen sie schon traf.
4. **Schild:** entscheidet die `Trefferzone`: das Eltern-Node setzt `schild_richtung`, `treffen()` gibt `GETROFFEN` oder `GEBLOCKT` zurück.
5. **Härte:** zweites Custom Data `haerte` am Tile, zweites Byte-Feld im `Gelaende`. Bisherige feste Kachel = hart, Plattform = weich, außerhalb des Rasters unzerstörbar.
6. **Blöcke zerstören:** direkt am Raster, `gelaende.block_zerstoeren(zelle, bricht_bis) -> bool`, Signal `block_zerstoert(zelle)` am `Gelaende`. Einsturz und Trümmer nicht in diesem Ticket.
7. **Kein `Ereignisse`-Autoload** jetzt; erst wenn jemand außerhalb der Szene es braucht.
8. **Einfrieren:** global über `Engine.time_scale`; in „Koop bauen“ prüfen, ob das zu zäh ist.
9. **Wackeln:** `Kamera` (`gemeinsam/kamera.gd`) mit `wackeln(staerke)` nach Trauma-Modell; der Ritter sendet `wackeln`, die Szene verbindet.
10. **Tod im Testraum:** Signal `gestorben`, nach 1 s Neustart mit wiederhergestellten Blöcken.
11. **Eingabe:** `angreifen` (X, F), `schild` (LB, LT, G), `bumerangaxt` (B, H); Sprinten ohne X. Nur linke Tastaturhälfte.
12. **Kollisionsebenen:** 1 „Ritter“, 2 „Gegner“.
13. **Testpuppe** in `ritter/testraum/testpuppe/`, **Geschoss** in `gemeinsam/geschoss/`.
14. **Tests** für Härte, Schild, Schlag/Powerschlag, Ladungen, Tod.
