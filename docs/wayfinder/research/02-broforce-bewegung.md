---
ticket: 02-broforce-bewegung
title: Wie fühlt sich Broforce-Bewegung an?
stand: 2026-11-01
---

# Broforce-Bewegung: Recherche und Nachbau in Godot 4.7

## Zusammenfassung

1. **Broforce nutzt keine Physik-Engine für die Figuren.** Die Figuren sind kinematisch; Laufen, Springen und Kollision sind von Hand geschrieben (Raycasts gegen ein 16er-Raster). Das ist der Kern des Spielgefühls.
2. **Einheiten = Pixel.** Ein Block ist 16 Einheiten groß, die Figur ist 12 breit und 18 hoch, ein Sprite-Bild 32 px. Alle Werte unten lassen sich 1:1 als Pixel übernehmen.
3. **Laufen:** Höchstgeschwindigkeit 110 px/s (knapp 7 Blöcke/s). Beim Drücken springt die Geschwindigkeit sofort auf 10–25 px/s, danach starke Beschleunigung. Volle Geschwindigkeit nach ca. 0,3 s. Sprinten: ×1,5.
4. **Bremsen:** Am Boden ohne Eingabe fast sofort (exponentielles Abbremsen, Rate ca. 10–25 pro Sekunde, also unter 0,15 s). In der Luft gibt es im Grundcode **keine** Luftreibung.
5. **Sprung:** Startgeschwindigkeit 260 px/s, die bis zu 0,123 s **konstant gehalten** wird, solange die Taste gedrückt ist (variable Sprunghöhe). Schwerkraft 1100 px/s². Kurzer Sprung ca. 31 px (2 Blöcke), voller Sprung ca. 60 px (knapp 4 Blöcke).
6. **Fallen:** Höchste Fallgeschwindigkeit 400 px/s. Sie ist nach ca. 0,36 s freiem Fall erreicht.
7. **Wand:** An der Wand rutscht man mit höchstens 40 px/s nach unten, kurz nach dem Kontakt „klebt“ man 0,2–0,25 s. Wandsprung = **senkrecht nach oben hüpfen** (260 px/s, horizontale Geschwindigkeit wird auf 0 gesetzt), nicht von der Wand wegtreten. Mehrfach gedrückt ergibt das das typische Hochklettern. Unter einem Überhang „flippt“ die Figur über die Kante (Chimney Flip).
8. **Komfort-Hilfen:** Jump Buffer 0,2 s (belegt). Coyote Time existiert (über `lastLandTime`), Wert unbekannt; Schätzung 0,08–0,1 s. Mindestabstand zwischen zwei Sprüngen 0,08 s.
9. **Kamera:** Eine gemeinsame Kamera, ca. 454 px breit, zoomt im Koop **nicht** heraus. Spieler werden am Bildrand festgehalten; wer unten aus dem Bild fällt, wird zurückgeholt.
10. **Treffer-Feedback:** Screenshake in festen Stufen (0,1 klein … 1,0 Explosion), Weißblitz auf getroffenen Figuren, viele Partikel (Funken, Staub, Splitter, Blut, Blitz-„Pop“). Ein globaler Hitstop ist im Grundcode **nicht** belegt. **Empfehlung Godot:** eigene AABB-Kollision gegen das Block-Raster statt `move_and_slide` (siehe unten, Option A).

## Quellenlage

Es gibt keinen GDC-Talk oder Postmortem von Free Lives, der Bewegungswerte nennt. Die Suche nach Interviews (GamingBolt, GamesBeat) lieferte nur Allgemeines zu Chaos und Zerstörung.

Die belastbarste Quelle ist die Modding-Community:

- **[alexneargarder/Broforce-Docs](https://github.com/alexneargarder/Broforce-Docs)** – XML-Dokumentation der Spielklassen (`TestVanDammeAnim` = Basisklasse aller Figuren, `BroBase`, `Map`, `CameraController`, `EffectsController`, `Block`). **Achtung:** Laut README wurde sie größtenteils von einer KI aus dem dekompilierten Code erzeugt. Die Zahlen sind plausibel und untereinander stimmig, aber nicht von Menschen geprüft.
- **[alexneargarder/BroforceMods](https://github.com/alexneargarder/BroforceMods)** – Mod-Quellcode. Die Datei `Furibrosa/Furibrosa/WarRig.cs` enthält überschriebene Kopien der originalen Methoden `CalculateMovement`, `RunMovement`, `Jump`, `AddSpeedLeft/Right`, `RunGroundFriction`. Damit lassen sich viele Doc-Angaben im echten Code nachprüfen. Weil es ein Fahrzeug ist, können einzelne Faktoren abgewandelt sein.
- Weitere Mod-Quellen für Screenshake-Stufen: [Gorzontrok/Mods-Broforce](https://github.com/Gorzontrok/Mods-Broforce), [Gorzontrok/CustomBros](https://github.com/Gorzontrok/CustomBros), [VojkanSE87/BroforceMods](https://github.com/VojkanSE87/BroforceMods).
- Spielerwissen: [Steam-Diskussion „Tips“](https://steamcommunity.com/app/274190/discussions/0/611701360820425405) (Überhang-Flip, Doppeltipp-Dash, Leitern), [WhatCulture-Review](https://whatculture.com/gaming/broforce-review-explosive-pixellated-all-american-carnage?page=2) (Kamera zoomt nicht heraus).

Kennzeichnung in den Tabellen:
- **B** = belegt im Code (Mod-Kopie des Originalcodes)
- **D** = laut Broforce-Docs (KI-generiert, plausibel)
- **S** = geschätzt / abgeleitet von mir

## Details

### Maßstab

| Wert | Broforce | Quelle |
|---|---|---|
| Blockgröße | 16 Einheiten (`Map.TileSize`, halbe Größe 8) | D |
| Figur, halbe Breite | 6 → Breite 12 | D (`halfWidth`) |
| Figur, Kopfhöhe stehend | 18 (Hüfte 10) | D (`standingHeadHeight`) |
| Sprite-Bild | 32 px hoch | D (`spritePixelHeight`) |
| Kamera, halbe Breite | 227 → Sicht ca. 454 Einheiten breit | D (`CameraController.DefaultHalfWidth`) |
| Einheit = Pixel | sehr wahrscheinlich (Sprite 32 px, Block 16 px) | S |
| Zeitschritt | variables `t`, begrenzt auf max. 0,0334 s | D (`SetDeltaTime`) |

Die Figur ist also gut einen Block hoch und knapp einen Block breit. Bei 16:9 und 454 px Breite sieht man ca. 28 × 16 Blöcke.

### Laufen, Beschleunigen, Bremsen

| Wert | Broforce | Quelle |
|---|---|---|
| Höchstgeschwindigkeit `speed` | 110 px/s | D, B (Mod setzt `speed = 110`) |
| Sofortiger Anschub beim Drücken | auf mind. 10 px/s (Doc) bzw. 25 px/s (Fahrzeug-Kopie) | D / B |
| Beschleunigung | `speed × 2 × t` (= 220 px/s²), beim Sprinten ×4 | D |
| Zusatz-Schub unter 50 px/s | `speed × 2,6 × t` (= 286 px/s²) | B, D |
| Sprint (`dashSpeedM`) | Höchstgeschwindigkeit ×1,5 = 165 px/s | B (Fahrzeug-Kopie), Basiswert S |
| Bremsen am Boden ohne Eingabe | `xI *= 1 − t × k`, k ≈ 10–25 (unter 50 px/s stärker) | D, B (Struktur) |
| Luftreibung | im Grundcode leer (`RunAirFriction` ohne Inhalt) | D |
| Kanten-Schutz | Helden rutschen beim Stehenbleiben nicht über Kanten (`DontSlipOverEdges`) | D |
| Dash per Doppeltipp | zweiter Tipp innerhalb 0,33 s | D, Steam-Tipps |

Was das bedeutet: Anlaufen geht von 10–25 auf 50 px/s in ca. 0,08 s, dann bis 110 px/s in weiteren ca. 0,27 s. Das fühlt sich direkt an, hat aber einen kleinen „Anschub“. Anhalten ist praktisch sofort. Richtungswechsel sind dadurch sehr schnell, weil der Anschub sofort auf die neue Seite setzt.

### Sprung und Schwerkraft

| Wert | Broforce | Quelle |
|---|---|---|
| Schwerkraft | 1100 px/s² (oft als Literal `1100f` im Code) | D, B |
| Sprungkraft `jumpForce` | 260 px/s | D, B (Mod setzt `jumpForce = 260`) |
| Haltezeit `JUMP_TIME` | 0,123 s (manche Stellen 0,13 s) | D, B |
| Mechanik variable Höhe | Solange Taste gehalten und `jumpTime > 0`: `yI = jumpForce` (konstant). Loslassen setzt `jumpTime = 0`. | B |
| Max. Fallgeschwindigkeit | −400 px/s | D |
| Mindestabstand zwischen Sprüngen | 0,08 s | B |
| Jump Buffer | Sprung in der Luft gedrückt → 0,2 s Fenster, bei Landung wird automatisch gesprungen | B (`pressedJumpInAirSoJumpIfTouchGroundGrace = 0.2f`) |
| Coyote Time | über `lastLandTime` vorhanden, Wert nicht gefunden | D, Wert S: 0,08–0,1 s |
| Plattform-Mitnahme | Sprung erbt Geschwindigkeit der Plattform (vertikal begrenzt auf −100…400) | B |

Abgeleitete Werte (S, gerechnet ohne Frame-Effekte):
- Kurzer Sprung (Tippen): 260² / (2 × 1100) ≈ **31 px ≈ 2 Blöcke**, Steigzeit 0,24 s.
- Voller Sprung: 260 × 0,123 + 31 ≈ **63 px ≈ 4 Blöcke** (real eher ~60, weil die Schwerkraft auch während der Haltezeit pro Frame abzieht). Steigzeit ca. 0,36 s, Gesamtflugzeit auf gleicher Höhe ca. 0,7 s.
- Freier Fall erreicht 400 px/s nach 0,36 s bzw. ca. 73 px Fallweg.

Wichtig für das Gefühl: Der Sprung ist **kein** klassischer Parabel-Sprung mit „Schwerkraft ×2 beim Loslassen“. Stattdessen gibt es eine kurze Phase mit konstanter Steiggeschwindigkeit. Das macht den Sprung schnell, kantig und gut steuerbar.

### Wand: Rutschen, Klettern, Wandsprung, Überhang-Flip

| Wert | Broforce | Quelle |
|---|---|---|
| Rutschen an der Wand (`wallDrag`) | Fall begrenzt auf −40 px/s, nach oben wird geklemmt | D (`ClampWallDragYI`) |
| Kleben nach Wandkontakt | `wallDragTime` 0,2 s (Doc) / 0,25 s (Code) | D, B |
| Wandsprung (`Jump(true)`) | `yI = 260`, `xI = 0`, **keine** Haltezeit (`jumpTime = 0`) → senkrechter Hüpfer ca. 31 px | B |
| Auslöser Wandsprung | Sprungtaste neu gedrückt, während man an der Wand rutscht und `yI < 25` und links/rechts gehalten wird | B |
| Klettern halten | Sprungtaste gehalten an der Wand → `wallClimbing`, `yI` mindestens 5 px/s, eigene reduzierte Schwerkraft | B, D |
| Klettern nur bei | `yI ≤ maxWallClimbYI` (100 px/s) | D |
| Abstand Wandsprünge | 0,2 s | D (`lastJumpTime`) |
| Chimney Flip | Springt man unter einen Überhang/Decke an einer Wand, flippt die Figur hoch über die Kante; `xI = ±100` für 11 Animationsbilder | D, B, [Steam-Tipps](https://steamcommunity.com/app/274190/discussions/0/611701360820425405) |
| Deckenhängen | nur bestimmte Figuren (`canCeilingHang`), Gnadenzeit 0,3 s | D |

Was das bedeutet: In Broforce klettert man Wände hoch, indem man Richtung Wand hält und Sprung wiederholt drückt. Jeder Druck ist ein kleiner senkrechter Hüpfer mit Messer-Stich-Animation. Man stößt sich **nicht** von der Wand ab wie in Mega Man X oder Celeste. Zusammen mit dem Chimney Flip kommt man fast jede Kante hoch. Das ist ein zentraler Teil des Spielgefühls.

### Leitern

| Wert | Broforce | Quelle |
|---|---|---|
| Einstieg | Oben drücken über einer Leiter, oder unten drücken ohne Boden darunter | B |
| Beim Einstieg | `yI = 0`, Air-Dash wird abgebrochen | B |
| Schwerkraft auf der Leiter | aus | D (`ApplyFallingGravity`) |
| Ausrichtung | Figur wird auf die Leiter-X-Position ausgerichtet (`ladderX`) | D |
| Mit Links/Rechts | man kann auf der Leiter seitlich steuern | [Steam-Tipps](https://steamcommunity.com/app/274190/discussions/0/611701360820425405) |
| Klettergeschwindigkeit | nicht gefunden | S: 80–110 px/s (ungefähr Laufgeschwindigkeit) |

### Kamera bei mehreren Spielern

| Aspekt | Broforce | Quelle |
|---|---|---|
| Kamera | eine gemeinsame Kamera (`SortOfFollow`) | Mod-Code |
| Sichtbreite | ca. 454 px, abhängig vom Seitenverhältnis | D |
| Zoom im Koop | kein Herauszoomen, um alle Spieler zu zeigen | [WhatCulture](https://whatculture.com/gaming/broforce-review-explosive-pixellated-all-american-carnage?page=2) |
| Bildrand | Spieler werden am Bildrand festgehalten (`ConstrainSpeedToSidesOfScreen`) | D |
| Unten aus dem Bild | Spieler wird nach kurzer Wartezeit zurück ins Bild teleportiert (`TeleportOnScreenCounter`) | D |
| Zoom | existiert für Sonderfälle (Deathmatch-Start, Zwischensequenzen: `IsZooming`, `ForceSlowSnapBackZoom`) | Mod-Code |

Welcher Punkt verfolgt wird (Mittelwert, führender Spieler), war nicht zu klären. Schätzung (S): Mittelwert aller lebenden Spieler mit Dämpfung, begrenzt durch die Bildränder.

### Treffer-Feedback

| Aspekt | Broforce | Quelle |
|---|---|---|
| Screenshake | `SortOfFollow.Shake(stärke[, dauer])`. Gefundene Stufen: 0,1 (kleiner Treffer), 0,15 (Nahkampf), 0,2–0,3 (mittel), 0,5 (groß), 1,0 (Explosion), `Shake(1, 2)` (Fahrzeug zerstört) | Mod-Code (mehrere Mods) |
| Explosionen | Shader-Explosion + Funken (Standard 40) + Weißblitz-„Pop“ + Bodenwelle + Bäume wackeln + Shake; große Explosionen zusätzlich Bildschirmblitz und Audiofilter | D (`EffectsController.CreateExplosion`, `CreateHugeExplosion`) |
| Treffer auf Figuren | Weißblitz (`Unit.flash`), Blutpartikel in 3 Größen, Rückstoß (`Knock`) | D |
| Blöcke | Splitter/Staub beim Zerstören; Blöcke darüber stürzen mit Verzögerung 0,2 s ein, Einsturz-Chance halbiert sich pro Ebene (×0,5) | D (`Block.collapseDelayTime`, `collapseChanceMultiplier`) |
| Hitstop | im Grundcode nicht belegt. Ein Mod nutzt 0,08–0,25 s Pause nach Nahkampftreffern (`postAttackHitPauseTime`) | Mod-Code (nicht original) |
| Sprung-Staub | „Jump Poof“ beim Absprung, Richtung abhängig von Laufgeschwindigkeit (≥ 30 px/s) | B |

## Startwerte für Eisen und Eid (Pixel, Sekunden)

Annahme: Blöcke 16 × 16 px, interne Auflösung z. B. 480 × 270 (30 × ca. 17 Blöcke, nah an Broforce). Die Ritter sind schwerer als Bros; wer das spüren will, nimmt die Werte in Klammern.

| Konstante | Startwert | Herkunft |
|---|---|---|
| `TILE` | 16 | B/D |
| Hitbox Ritter | 12 × 18 (gebückt kleiner) | D |
| `RUN_SPEED` | 110 (100) | D |
| `RUN_KICK` (Anschub beim Drücken) | 25 | B |
| `RUN_ACCEL` | 220, unter 50 px/s zusätzlich 286 | D/B |
| `SPRINT_MULT` | 1,5 | B |
| `GROUND_FRICTION_RATE` | 20 (`v *= 1 − rate × dt`) | D, Wert S |
| `AIR_FRICTION` | 0 | D |
| `GRAVITY` | 1100 | D/B |
| `JUMP_SPEED` | 260 (240) | D/B |
| `JUMP_HOLD_TIME` | 0,123 | D/B |
| `MAX_FALL` | 400 | D |
| `JUMP_BUFFER` | 0,2 | B |
| `COYOTE_TIME` | 0,08 | S |
| `JUMP_COOLDOWN` | 0,08 | B |
| `WALL_SLIDE_MAX` | 40 | D |
| `WALL_STICK_TIME` | 0,2 | D/B |
| `WALL_HOP_SPEED` | 260, ohne Haltezeit, `vx = 0` | B |
| `WALL_CLIMB_MAX_VY` | 100 | D |
| `LADDER_SPEED` | 90 | S |
| `MAX_DT` | 1/30 | D |
| Screenshake-Stufen | 0,1 / 0,15 / 0,3 / 0,5 / 1,0 → z. B. ×4 px Ausschlag, Abklingen in 0,2–0,5 s | Stufen Mod-Code, Pixel S |
| Hitstop (optional) | 0,05–0,1 s bei Schwert-Treffern | S, angelehnt an Mod |

Achtung: Diese Werte sind **pro Sekunde** gedacht und gehören in einen Code mit `delta`. Broforce selbst rechnet mit variablem Zeitschritt; in Godot ist `_physics_process` mit festen 60 Hz einfacher und für lokalen Mehrspieler deterministischer.

## Empfehlung für Godot 4.7

Die Frage ist: Sollen die Figuren über Godots Physik (`CharacterBody2D` + `move_and_slide`) laufen oder über eine eigene Kollision gegen das Block-Raster?

**A (empfohlen): Eigene AABB-Kollision gegen das Block-Raster.**
Die Figur ist ein `Node2D` mit eigener Position, Geschwindigkeit und Hitbox. Pro Physik-Frame: erst X bewegen und gegen belegte Rasterzellen auflösen, dann Y. Abfragen wie „Wand vorne?“, „Boden unter mir?“, „Decke über dem Kopf?“ sind einfache Zellen-Abfragen auf demselben Array, das auch die Zerstörung verwaltet.
- Pro: Genau so arbeitet Broforce (Raycasts gegen ein 16er-Raster, keine Physik-Engine). Pixelgenau und vorhersagbar. Keine Verzögerung zwischen „Block zerstört“ und „Kollision weg“. Kein Hängenbleiben an Kachel-Nähten. Billig auch mit 4 Spielern und vielen Gegnern. Wandklettern, Chimney Flip und Kanten-Schutz lassen sich direkt nachbauen.
- Contra: Mehr eigener Code (ca. 150–300 Zeilen für den Kern). Schräge Flächen gibt es nicht (Broforce hat auch keine). Für Trümmer und Leichen braucht man entweder ebenfalls eigenen Code oder doch Godot-Physik.

**B: `CharacterBody2D` + `move_and_slide` gegen einen `TileMapLayer`.**
- Pro: Schneller Start, `is_on_floor()`/`is_on_wall()` sind eingebaut, Godot-Doku und Tutorials passen direkt.
- Contra: Beim Zerstören von Kacheln baut Godot die Kollisionsformen neu; bei vielen gleichzeitigen Explosionen kann das teuer werden. `move_and_slide` hat eigenes Verhalten (Floor-Snap, Sicherheitsabstand, Gleiten), das man gegen den Broforce-Stil abschalten oder umgehen muss. Die Rasterlogik für Zerstörung und die Physikformen sind zwei getrennte Datenquellen.

**C: Mischung.** Figuren und Gegner mit eigener Kollision (A), Trümmer, Leichen und herumfliegende Teile als `RigidBody2D` mit Godot-Physik.
- Pro: Spielgefühl der Figuren wie in A, trotzdem „echte“ Physik für Effekte.
- Contra: Zwei Kollisionssysteme müssen dasselbe Gelände kennen (Raster-Array und Kachel-Kollision).

Mein Vorschlag ist **A**, für Trümmer später bei Bedarf C. Grund: Das Spielgefühl hat oberste Priorität, und Broforce selbst ist genau so gebaut. Bei B kämpft man am Ende gegen die Eigenheiten von `move_and_slide`, um das kantige Broforce-Verhalten zu bekommen.

Weitere Hinweise zum Nachbau:
- Bewegung immer in ganzen Pixeln darstellen (Position als Float rechnen, beim Zeichnen runden), sonst flimmert Pixelgrafik.
- Reihenfolge pro Frame wie in Broforce: Eingabe → Geschwindigkeit setzen (Sprung halten, Anlauf, Bremsen) → Schwerkraft → Fallgeschwindigkeit begrenzen → erst X, dann Y verschieben und gegen das Raster auflösen → Landen/Wand-Zustand setzen.
- Kamera: `Camera2D` auf den Mittelpunkt aller lebenden Spieler, feste Zoomstufe, Spieler per Code an die Bildränder klemmen. Screenshake als Versatz der Kamera mit Abklingen.
- Werte als `@export` oder in einer eigenen `Resource` ablegen, damit man im Editor live nachjustieren kann. Die Zahlen oben sind ein Startpunkt; das letzte Wort hat das Ausprobieren mit Controller.

## Offene Punkte

- Coyote-Time-Wert, Leiter-Geschwindigkeit, genaue Wandkletter-Schwerkraft und Kamera-Folgelogik (`SortOfFollow`) sind nicht belegt. Wer sie exakt braucht, müsste `Assembly-CSharp.dll` des gekauften Spiels selbst mit dnSpy/ILSpy ansehen. Das ist eine Entscheidung für den Menschen (Lizenzfrage, Werkzeug installieren).
- Die Broforce-Docs sind KI-generiert. Die im Mod-Code nachprüfbaren Werte (Sprung, Schwerkraft, Buffer, Wandsprung, Anlauf) stimmen mit den Docs überein; das spricht für ihre Verlässlichkeit, garantiert sie aber nicht.
