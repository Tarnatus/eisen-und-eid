---
title: "Palermo: Aufbau und Gegner"
type: grilling
status: closed
assignee: fjw
blocked_by: [04, 06]
---

## Question

Wie ist das Prototyp-Level Palermo aufgebaut (Länge, Abschnitte, Dächer, Mauern, Kamelherden, Gefangene, Fässer/Gags) und welche Gegnertypen kommen vor?

## Hinweise

- Aus „Koop-Regeln für 1–4 Spieler“: Gefangene bringen +1 Leben. Fundstücke (z. B. Kisten oder Fässer) geben neue Bumerangaxt-Ladungen; Art und Platzierung hier festlegen.
- Normale Gegner skalieren nicht mit der Spielerzahl. Es gibt keine Checkpoints; das Ross bringt Ritter ins aktuelle Bild.

## Resolution

Entschieden im Gespräch, 2026-11-01:

| Thema | Entscheidung |
|---|---|
| Länge | Etwa 3–4 Minuten bis zur Boss-Arena, rund 10 Bildbreiten (≈ 300 Blöcke). |
| Richtung | Hauptsächlich nach rechts, dazu ein senkrechter Aufstieg (Stadtmauer) und ein Abstieg (Gewölbe unter der Altstadt). Keine verzweigten Wege. |
| Abschnitte | 1. **Hafen** (~2 Bilder): Landung vom Schiff, flach, Einstieg mit Säbelkämpfern, Beilkiste, offenem Gefangenen. 2. **Lagerhäuser** (~2 Bilder): Holzbauten, Ölfässer, Bogenschützen auf Dächern, erste Kettenexplosion. 3. **Stadtmauer** (~2 Bilder, senkrecht): harter Stein, außen hochklettern oder mit Powerschlag durchbrechen; oben Katapult und Schildträger. 4. **Altstadt** (~2 Bilder): über Dächer, dann durch weiche Erde hinab ins Gewölbe mit verstecktem Gefangenen, wieder hoch. 5. **Markt** (~1–2 Bilder): Kamelherde quer über den Platz, Rettung nach oben auf Stände und Plattformen. 6. **Tor zur Arena**: Übergang zum Boss; die Arena gehört zu „Kamelhauptmann: Boss-Design“. |
| Gegnertypen | **Säbelkämpfer** (Nahkampf, die Masse), **Bogenschütze** (hält Abstand, schießt gerade oder im Bogen; Schild hält Pfeile ab), **Schildträger** (blockt vorn, rückt langsam vor). Schleuderer aus dem Webspiel entfällt. |
| Treffer an Gegnern | 1 Treffer tötet. Schildträger: Schlag von vorn prallt ab; Powerschlag von vorn schlägt den Schild weg, danach tötet 1 Treffer; von oben, hinten und durch die Bumerangaxt sofort tot. |
| Verhalten | Gegner stehen oder patrouillieren kurz. Sehen sie einen Ritter: „!“, nach ca. 0,5 s Angriff (Wert wird abgestimmt), Nachbarn in der Nähe werden alarmiert. |
| Gegnerzahl | Etwa 30, in Gruppen von 3–6 an gestalteten Stellen (neben Fässern, auf Dächern, an der Mauer), dazwischen ruhige Stücke. Keine Skalierung mit der Spielerzahl. |
| Katapult | Eins, fest oben auf der Stadtmauer. Schießt Steine, die Blöcke zerstören; Ritter müssen sich hinkämpfen. |
| Ölfässer | Explodieren bei Treffer, zerstören weiche und harte Blöcke im Radius, töten Gegner **und Ritter** (Umwelt, kein Friendly Fire). Kettenreaktionen. Radius wird abgestimmt. |
| Gefangene | 4, in Käfigen. Jeder Treffer öffnet den Käfig, auch Explosion, Bumerangaxt oder Absturz. Gefangene sterben nie. +1 Leben. Einige offen, einige versteckt (hinter weichen Blöcken, auf Umwegen). |
| Beilkisten | Holzkisten (weich), 4–5 im Level vor schweren Stellen. Zerschlagen lässt 1 Bumerangaxt-Ladung fallen, aufsammeln durch Darüberlaufen (höchstens 3). |
| Kamelherde | Einmal im Level (Markt) als Vorgeschmack auf den Boss: mit Warnung, quer durch den Abschnitt, man springt darüber oder flüchtet nach oben. Wird für den Boss wiederverwendet. |
| Stürze | Kein Fallschaden für Ritter und Gegner. Unten aus dem Level = tot. Gegner fallen mit, wenn Blöcke unter ihnen zerbrechen. |
| Level bauen | In einer `TileMapLayer` malen, Härte als Custom Data im TileSet; beim Start liest das Spiel die Zellen ins Raster. Gegner, Fässer, Käfige, Beilkisten als Szenen hineingesetzt. Agenten bauen mit einem Headless-GDScript (`set_cell`, Szene speichern), ohne den Editor zu öffnen; der Godot-MCP-Server kann keine Zellen setzen. Nachteil: `tile_map_data` ist im Git-Diff nicht lesbar. |

Neue Begriffe im Glossar: Gegner, Säbelkämpfer, Bogenschütze, Schildträger, Katapult, Ölfass, Beilkiste, Kamelherde.

Bau: „Gegner bauen“, „Palermo bauen“.
