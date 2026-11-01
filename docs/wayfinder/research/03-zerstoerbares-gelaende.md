---
ticket: 03-zerstoerbares-gelaende
title: Wie baut man zerstörbares Block-Gelände in Godot 4.7?
stand: 2026-11-01
godot_lokal: 4.7.2.stable.official.ed1daf0bf
---

# Zerstörbares Block-Gelände in Godot 4.7

## Zusammenfassung

1. **Installiert ist Godot 4.7.2 stable** (`godot --version`). Alle Aussagen unten beziehen sich auf 4.5 bis 4.7.
2. **TileMapLayer reicht für Broforce-artiges Gelände.** `set_cell`/`erase_cell` zur Laufzeit sind vorgesehen. Alle Änderungen eines Frames werden gesammelt und am Frame-Ende in einem Durchgang verarbeitet. Eine Explosion mit vielen Blöcken kostet also ungefähr ein Update, nicht eines pro Block.
3. **Seit 4.5 werden Tile-Kollisionen in „Physics Quadrants“ zusammengefasst** (`physics_quadrant_size`, Standard 16 → 16×16 Zellen pro Body). Das hat die Physik-Performance stark verbessert und Ghost-Collisions an Tile-Kanten deutlich seltener gemacht. Sie verschwinden aber nicht ganz.
4. **Die Kehrseite:** Wird ein Tile geändert, wird der **ganze Quadrant** neu gebaut. Außerdem liefert `get_coords_for_body_rid()` nur noch den Quadranten, nicht mehr die getroffene Zelle. Für zerstörbares Gelände empfiehlt sich deshalb eine kleinere Quadrantengröße (geschätzt 4–8). Die getroffene Zelle bestimmt man über den Trefferpunkt.
5. **Die Spiellogik (Lebenspunkte, Material, Statik) sollte in einem eigenen Raster liegen.** Die TileMapLayer dient nur zur Darstellung und als Kollision. Explosionen fragen das Raster ab, nicht die Physik.
6. **Einsturz nicht gestützter Blöcke:** Nach jeder Zerstörung einen Flood-Fill von „verankerten“ Blöcken aus starten, nur in der betroffenen Region. Nicht verbundene Gruppen werden zu fallenden Objekten. Dafür gibt es kein fertiges Godot-Feature. Das ist Eigenbau.
7. **Trümmer:** Für die Optik `GPUParticles2D`/`CPUParticles2D` verwenden. GPU-Partikel kollidieren nur mit `LightOccluder2D`, nicht mit Physik-Bodies. Echte `RigidBody2D`-Trümmer nur sparsam einsetzen, z. B. ein paar Brocken pro Explosion.
8. **Ein eigenes AABB-Raster mit eigener Kollision gibt die meiste Kontrolle über das Spielgefühl.** Es bedeutet aber, die Bewegungsphysik für alle Figuren selbst zu schreiben. Für den Prototyp ist es nicht nötig, als Plan B aber realistisch.
9. **Neuerungen in 4.4–4.7:** Das TileMapLayer-Chunking (4.5) ist die relevanteste Änderung. 2D-Physik-Interpolation gibt es seit 4.3. In 4.7 kam `one_way_collision_direction` für `CollisionShape2D` dazu. **Jolt ist nur für 3D.** Für 2D bleibt GodotPhysics2D.
10. **Broforce:** Belegt sind Unity, „brick-based destructible terrain“ und Levels, die bewusst kurz vor dem Einsturz gebaut sind. **Nicht belegt** sind Blockgröße (16 px?) und die interne Umsetzung.

---

## 1. Ansätze

### A. TileMapLayer als Darstellung und Kollision, eigenes Datenraster für die Logik (empfohlen)

So funktioniert es:
- Eine `TileMapLayer` „Zerstörbar“ mit Physics Layer im TileSet. Eventuell eine zweite Layer für unzerstörbare Blöcke und Hintergrund.
- Parallel dazu ein `Dictionary[Vector2i, BlockData]` oder ein flaches `PackedInt32Array` mit Material, Lebenspunkten und Flag „verankert“.
- Treffer: Aus Trefferpunkt und Normale die Zelle berechnen: `local_to_map(to_local(point - normal * 0.5))`. Dann Lebenspunkte im Raster abziehen. Ist der Block zerstört, `erase_cell()` oder per `set_cell()` ein „beschädigtes“ Tile setzen.
- Explosion: Alle Zellen im Radius über das Raster durchgehen (Kreis gegen Zellmittelpunkt). Schaden nach Entfernung abstufen. Physik wird dafür nicht gebraucht.

Pro:
- Eingebautes Rendering, Autotiling (Terrains), Editor zum Bauen der Levels.
- `CharacterBody2D` mit `move_and_slide` funktioniert sofort.
- Updates werden pro Frame gesammelt (belegt, Doku).
- Seit 4.5 werden Kollisionen zusammengefasst, das ist schnell (belegt, PR #102662).

Contra:
- Jede Änderung baut den ganzen Physik- und Render-Quadranten neu. Bei großen Quadranten und vielen Explosionen kann das Frame-Spitzen erzeugen (Mechanismus belegt, Größenordnung nicht gemessen).
- `get_coords_for_body_rid()` ist für die Zellsuche ab 4.5 unbrauchbar, außer bei `physics_quadrant_size = 1` (belegt). Workaround: Trefferpunkt plus Normale.
- Ghost-Collisions und Hängenbleiben an Kanten sind seltener, aber an Quadrantengrenzen weiterhin möglich (belegt, PR-Diskussion).
- Lebenspunkte als TileSet-Custom-Data mit `_use_tile_data_runtime_update` sind laut Doku teuer. Deshalb die Lebenspunkte im eigenen Raster halten (belegt, Doku-Warnung).

### B. Eigenes Block-Raster mit eigener AABB-Kollision, Darstellung per TileMapLayer (ohne Physik) oder MultiMesh

So funktioniert es:
- Das Raster ist die einzige Quelle für Kollisionen.
- Figuren bewegen sich mit eigener Logik: erst X, dann Y, jeweils gegen die belegten Zellen der AABB prüfen. Das ist der klassische Ansatz aus Celeste und TowerFall.
- Rendering über eine TileMapLayer ohne Physics Layer oder über `MultiMeshInstance2D`.

Pro:
- Keine Ghost-Collisions, kein Hängenbleiben an Kanten. Kollision und Spielgefühl sind pixelgenau kontrollierbar.
- Ein Block ändern kostet nur ein Array-Write. Es wird nichts neu gebaut.
- Deterministisch. Das hilft beim späteren Online-Modus (das Repo hat bereits eine P2P-Lobby).

Contra:
- Bewegung, Schrägen, One-Way-Plattformen, Projektile und Gegner-Kollisionen müssen komplett selbst geschrieben werden. `move_and_slide`, Areas und Raycasts gegen das Gelände fallen weg oder brauchen Brücken-Code.
- Mehr Code im Prototyp, also langsamere erste Iteration.
- MultiMesh bringt gegenüber TileMapLayer für statisches Gelände kaum Vorteile (geschätzt). Autotiling geht dabei verloren.

### C. Ein StaticBody2D pro Block (Node pro Block)

Pro: Sehr einfach zu verstehen. Lebenspunkte und Signale hängen direkt am Block.
Contra: Tausende Nodes und Bodies. Genau das Problem, das Godot mit dem Chunking in 4.5 gelöst hat: Vorher gab es in Calinous Test mit 1000 RigidBodies „physics spiral of death“ mit 8–11 FPS. Für ganze Level nicht zu empfehlen. Für Sonderobjekte wie Fässer, Kisten oder Türme ist es in Ordnung.

### D. Pixel- oder Polygon-Destruktion (Worms-artig, `Geometry2D.clip_polygons`)

Passt nicht zu Broforce, das blockweise zerstört. Wird hier nur der Vollständigkeit halber erwähnt.

---

## 2. Lebenspunkte, Material, Einsturz, Trümmer

**Materialien** (Werte geschätzt, zum Tunen):

| Material | LP | Verhalten |
|---|---|---|
| Erde | 1 | zerfällt sofort, Staubpartikel |
| Holz | 2 | splittert, kann brennen (später) |
| Stein | 4 | erst beschädigtes Tile, dann zerstört |
| Fels/Rand | ∞ | verankert, unzerstörbar |

Schaden in Stufen über verschiedene Atlas-Koordinaten zeigen, also mit `set_cell` auf ein „rissiges“ Tile wechseln.

**Einsturz** (Eigenbau, geschätzt):
- Nach einer Zerstörung die Nachbarn der zerstörten Zellen sammeln.
- Für jede Nachbargruppe per BFS prüfen, ob sie mit einem verankerten Block verbunden ist. Die Suche bricht ab, sobald ein Anker gefunden ist. Zusätzlich die Suchtiefe begrenzen, sonst wird es bei großen Levels teuer.
- Nicht verbundene Gruppen aus der TileMapLayer entfernen und als „fallenden Block“ weiterführen, z. B. als `CharacterBody2D` oder `AnimatableBody2D` mit dem Tile als Sprite. Beim Aufprall wieder einrasten oder zerbrechen und Schaden verursachen.
- Kettenreaktionen über einen Frame-Verzug: Die Prüfung erst im nächsten Physik-Tick ausführen. Das verteilt die Kosten und sieht „bröckeliger“ aus.
- Broforce-Bezug: Levels „poised to self destruct“, Kettenreaktionen als Kern des Spielgefühls (belegt, Interview). Wie genau Broforce Stabilität berechnet, ist nicht belegt.

**Trümmer:**
- `GPUParticles2D` mit `collision_mode = COLLISION_RIGID` kollidieren nur mit `LightOccluder2D`, nicht mit PhysicsBody2D. Partikel sind immer kugelförmig (belegt, Klassen-Doku). Die Occlusion-Layer der TileMapLayer kann diese Occluder liefern. Sie wird bei Zerstörung aber ebenfalls neu gebaut.
- `CPUParticles2D` haben keine Weltkollision. Für kurzen Staub und Splitter reicht das.
- `RigidBody2D`-Trümmer nur wenige pro Explosion (Richtwert geschätzt: höchstens 4–8) mit Lebenszeit von 1–2 s. Bei 4 Spielern und Dauerfeuer sonst zu teuer.

---

## 3. Kollisionsprobleme und Gegenmittel

- **Ghost-Collisions an Tile-Kanten:** Durch das Chunking ab 4.5 „much rarer and less severe“, aber an Quadrantengrenzen weiterhin möglich (belegt, PR #102662). In der PR wurden Skimming im Character Controller und abgeschrägte Kanten diskutiert.
- **Gegenmittel** (Community, nicht offiziell geprüft):
  - Kleine Abschrägung an den unteren Ecken der Spielerform.
  - `floor_snap_length` erhöhen.
  - `safe_margin` anpassen.
  - Kapsel statt Rechteck. Für Broforce-Feeling sind Rechteck-Kanten an Plattformrändern aber eher gewünscht, deshalb mit Vorsicht.
- **Hängenbleiben an Ecken beim Springen:** Corner-Correction selbst bauen. Wenn der Kopf nur wenige Pixel eine Kante streift, den Spieler seitlich verschieben (Celeste-Technik, geschätzt 2–4 px).
- **Pixel-Jitter:** 2D-Physik-Interpolation gibt es seit 4.3. Bei Pixelgrafik zusätzlich die Kamera runden. „Snap 2D Transforms“ und „Snap 2D Vertices“ nicht kombinieren (Community).

---

## 4. Godot 4.4–4.7: was relevant ist

| Version | Neuerung | Relevanz |
|---|---|---|
| 4.3 | 2D-Physik-Interpolation | Glatte Bewegung bei festem Physik-Tick |
| 4.4 | Jolt als 3D-Option | **keine** für 2D |
| 4.5 | TileMapLayer-Physik-Chunking (`physics_quadrant_size`), Breaking Change bei `get_coords_for_body_rid` | **hoch** |
| 4.6 | Jolt Standard für neue 3D-Projekte | keine für 2D |
| 4.7 | `CollisionShape2D.one_way_collision_direction`, Scene Paint Mode im 2D-Editor, `DrawableTexture2D` | gering bis mittel (Paint Mode für Gegner und Kisten im Level) |

Zu TileMapLayer oder 2D-Physik stehen in den 4.7-Release-Notes keine Änderungen.

---

## 5. Belegt vs. geschätzt

**Belegt (Quelle vorhanden):**
- Updates werden am Frame-Ende gesammelt. `update_internals()` ist teuer. Runtime-Tile-Data kostet viel (Doku 4.7).
- `physics_quadrant_size` ist standardmäßig 16 und fasst Formen zusammen. Bei 1 ist das Chunking aus (Doku 4.7).
- Chunking kam in 4.5. Eine Tile-Änderung baut den ganzen Chunk neu. Seams werden seltener, verschwinden aber nicht. Riesige Chunks sind für dynamische Objekte schlecht. Benchmark: 8–11 FPS vorher, rund 490–900 FPS nachher bei 1000 RigidBodies (PR #102662).
- `get_coords_for_body_rid` liefert ab 4.5 keine Zelle mehr. Workaround ist Quadrantengröße 1 (Forum).
- GPUParticles2D kollidieren nur mit LightOccluder2D (Doku).
- Jolt ist nur für 3D. Die Release-Notes nennen 2D nicht.
- Broforce: Unity, „brick-based destructible terrain“, Prototyp aus Ludum Dare 23, Levels „poised to self destruct“, Fokus auf Kettenreaktionen.

**Geschätzt (eigene Einschätzung, im Prototyp prüfen):**
- Quadrantengröße 4–8 für zerstörbare Layer als guter Kompromiss.
- Broforce-Blockgröße 16 px. **Nicht belegt**, keine Quelle gefunden.
- Werte für Lebenspunkte und Trümmer-Anzahl, BFS-Tiefenlimit.
- Dass ein eigenes AABB-Raster für Broforce-Feeling „besser“ ist. Das hängt davon ab, wie gut `CharacterBody2D` sich tunen lässt.

---

## 6. Empfehlung für den Prototyp

**Ansatz A:** Eine TileMapLayer für Darstellung und Kollision, die Spiellogik in einem eigenen Raster.

Warum: schnellste Iteration, Editor und Autotiling inklusive, `CharacterBody2D` sofort nutzbar. Die bekannten Probleme lassen sich lokal beheben (Quadrantengröße, Trefferpunkt-Logik, Corner-Correction).

Konkret:
1. Zwei Layer: `Gelaende_Fest` (unzerstörbar, Quadrant 16) und `Gelaende_Zerstoerbar` (Quadrant 8, später messen).
2. `BlockGrid` als eigenes Skript mit Material und Lebenspunkten pro Zelle. Es ist die einzige Wahrheit. Die TileMapLayer wird nur daraus geschrieben.
3. Explosionen über das Raster abfragen (`damage_circle(center, radius, dmg)`), Treffer über Trefferpunkt plus Normale.
4. Einsturz per begrenztem BFS im nächsten Tick, fallende Gruppen als einfache Körper.
5. Trümmer als CPUParticles2D (Staub, Splitter) plus wenige RigidBody2D-Brocken.
6. Physik-Interpolation an, Kamera runden. Mit dem Debugger (Monitors: Physics, Frame Time) bei 4 Spielern und Dauerexplosionen messen.

**Wechsel zu Ansatz B (eigene AABB-Kollision)**, falls sich nach dem ersten Spielgefühl-Test zeigt, dass `move_and_slide` an Kanten oder Ecken stört. Oder falls der Online-Modus deterministische Physik braucht. Die Trennung von Raster und Darstellung aus Schritt 2 macht diesen Wechsel billig. Nur der Bewegungscode wird ersetzt.

**Offene Architekturfrage für das Team:** Soll das Raster von Anfang an deterministisch angelegt werden (feste Zellgröße, Ganzzahl-Positionen), damit Online später leichter wird?
- **A (Vorschlag):** Nein, erst Spielgefühl lokal. Der Wechsel ist dank Raster-Trennung billig.
- **B:** Ja, von Anfang an. Pro: kein späterer Umbau. Contra: langsamere erste Iteration.

---

## Quellen

- TileMapLayer-Klassendoku (4.7 stable): https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html
- TileMapLayer-Doku 4.5: https://docs.godotengine.org/en/4.5/classes/class_tilemaplayer.html
- PR #102662 „TileMapLayer physics chunking“: https://github.com/godotengine/godot/pull/102662
- Forum, Zellkoordinaten nach 4.5: https://forum.godotengine.org/t/is-there-a-way-to-find-an-individual-tiles-coordinates-in-godot-4-5/127295
- Forum, Ghost Collision TileMapLayer: https://forum.godotengine.org/t/is-godot-tilemaplayer-ghost-collision-fixed/145465
- GitHub-Issue RigidBody zwischen Tiles: https://github.com/godotengine/godot/issues/93509
- Community-Guides Kanten/Ecken (SEO-lastig, ungeprüft): https://bugnet.io/blog/fix-godot-character-body-2d-stuck-on-tile-corners , https://bugnet.io/blog/how-to-fix-godot-characterbody2d-catching-on-tilemap-collision-edges
- TileMap Collision Baker (Addon): https://store.godotengine.org/asset/nickotato/tilemap-collision-baker/
- GPUParticles2D-Klassendoku: https://docs.godotengine.org/en/stable/classes/class_gpuparticles2d.html
- Godot 4.7 Release: https://godotengine.org/releases/4.7/
- Godot 4.6 Release (Jolt): https://godotengine.org/releases/4.6/
- Forum, Physik-Interpolation 4.3: https://forum.godotengine.org/t/problem-with-physics-interpolation-in-godot-4-3/96646
- Forum, Pixel-Art-Jitter: https://forum.godotengine.org/t/pixel-art-jittering/75305
- Broforce-Interview (GamingBolt, 2015): https://gamingbolt.com/?p=219918
- Broforce auf MobyGames: https://www.mobygames.com/game/75761/
- Broforce IGF-Eintrag: https://igf.com/broforce
- Broforce-Modding (für spätere Code-Einsicht): https://github.com/Gorzontrok/Mods-Broforce
