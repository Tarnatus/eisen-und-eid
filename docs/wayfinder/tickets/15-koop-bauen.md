---
title: Koop bauen
type: task
status: open
assignee:
blocked_by: [07, 12, 13]
---

## Question

Die Koop-Regeln aus „Koop-Regeln für 1–4 Spieler“ in den echten Ritter bauen:

- Bis zu 4 Spieler: Gamepads und zwei Tastaturhälften als getrennte Geräte. Tastaturbelegung siehe „Koop-Regeln für 1–4 Spieler“; die Eingabe-Aktionen in `project.godot` müssen pro Spieler unterscheidbar werden.
- Autoload `Mitspieler`: wer mit welchem Gerät mitspielt, wer schon einmal beigetreten war.
- Drop-in mit „Springen“, Austritt durch Gamepad trennen oder Halten von Select/Back bzw. Tab/Rücktaste.
- Gemeinsamer Vorrat an Leben (3 pro erstem Beitritt), Game Over, wenn alle tot sind und keine Leben übrig sind (vorerst einfach Neustart des Levels; das richtige Ende kommt mit „Start und Ende eines Durchlaufs“).
- Ross: reitet von links ins Bild, wirft den Ritter auf einem sicheren Block ab, verschwindet; beim Austritt holt es ihn ab. Wartezeit ca. 2 s, Schutz nach Landung ca. 1,5 s mit Blinken.
- Bumerangaxt-Ladungen beim Wiedereinstieg wieder auf 3.
- Kamera: Mitte aller lebenden Ritter, Bildrand als Wand seitlich und oben, unten raus = tot.
- Powerschlag stößt Mitspieler zurück, ohne Schaden.
- Testszene: mehrere Ritter gleichzeitig, Abgründe, ein Gefangener als Platzhalter für +1 Leben.

Abzustimmen: Startleben, Wartezeit, Schutzdauer, Tastaturbelegung, Rückstoß unter Mitspielern. Fertig, wenn vier Spieler gemeinsam durch die Testszene kommen; die abgestimmten Werte stehen in der Resolution.
