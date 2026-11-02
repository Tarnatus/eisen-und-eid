extends GdUnitTestSuite
## Tests für den Bewegungs-Baustein: Kasten gegen das Block-Raster.

const DT: float = 1.0 / 60.0
const FEST: Vector2i = Vector2i(0, 0)
const PLATTFORM: Vector2i = Vector2i(1, 0)


## Gelände 10 × 10 Blöcke mit Boden in Zeile 9; zusätzliche Zellen nach Wunsch.
func _gelaende(zellen: Dictionary[Vector2i, Vector2i] = {}) -> Gelaende:
	var gelaende: Gelaende = (load("res://gelaende/gelaende.tscn") as PackedScene).instantiate()
	var bloecke: TileMapLayer = gelaende.get_node("Bloecke")
	for spalte: int in range(10):
		bloecke.set_cell(Vector2i(spalte, 9), 0, FEST)
	bloecke.set_cell(Vector2i(0, 0), 0, FEST)  # legt die Oberkante des Rasters fest
	for zelle: Vector2i in zellen:
		bloecke.set_cell(zelle, 0, zellen[zelle])
	add_child(gelaende)
	auto_free(gelaende)
	return gelaende


func _koerper(gelaende: Gelaende, fuesse: Vector2) -> Koerper:
	var koerper: Koerper = auto_free(Koerper.new())
	koerper.gelaende = gelaende
	koerper.position = fuesse
	return koerper


func _schritte(koerper: Koerper, anzahl: int) -> void:
	for i: int in range(anzahl):
		koerper.schwerkraft_anwenden(DT)
		koerper.bewegen(DT)


func test_faellt_und_landet_auf_dem_boden() -> void:
	var koerper := _koerper(_gelaende(), Vector2(40.0, 60.0))
	_schritte(koerper, 120)
	assert_float(koerper.position.y).is_equal(9.0 * 16.0)
	assert_bool(koerper.auf_boden).is_true()
	assert_float(koerper.geschwindigkeit.y).is_equal(0.0)


func test_plattform_traegt_von_oben() -> void:
	var koerper := _koerper(_gelaende({Vector2i(2, 5): PLATTFORM}), Vector2(40.0, 40.0))
	_schritte(koerper, 60)
	assert_float(koerper.position.y).is_equal(5.0 * 16.0)
	assert_bool(koerper.auf_boden).is_true()


func test_plattform_laesst_von_unten_durch() -> void:
	var koerper := _koerper(_gelaende({Vector2i(2, 5): PLATTFORM}), Vector2(40.0, 9.0 * 16.0))
	koerper.geschwindigkeit.y = -300.0
	koerper.bewegen(0.2)
	assert_float(koerper.position.y).is_equal(9.0 * 16.0 - 60.0)
	assert_bool(koerper.an_decke).is_false()


func test_durch_plattform_fallen() -> void:
	var koerper := _koerper(_gelaende({Vector2i(2, 5): PLATTFORM}), Vector2(40.0, 5.0 * 16.0))
	koerper.bewegen(DT)
	assert_bool(koerper.auf_boden).is_true()
	koerper.durch_plattformen_fallen(0.15)
	_schritte(koerper, 120)
	assert_float(koerper.position.y).is_equal(9.0 * 16.0)


func test_feste_decke_stoppt_steigen() -> void:
	var koerper := _koerper(_gelaende({Vector2i(2, 5): FEST}), Vector2(40.0, 9.0 * 16.0))
	koerper.geschwindigkeit.y = -300.0
	koerper.bewegen(0.2)
	assert_bool(koerper.an_decke).is_true()
	assert_float(koerper.position.y).is_equal(6.0 * 16.0 + koerper.hoehe)
	assert_float(koerper.geschwindigkeit.y).is_equal(0.0)


func test_wand_stoppt_und_wird_erkannt() -> void:
	var koerper := _koerper(_gelaende({Vector2i(5, 8): FEST}), Vector2(60.0, 9.0 * 16.0))
	koerper.geschwindigkeit.x = 200.0
	koerper.bewegen(0.2)
	assert_float(koerper.position.x).is_equal(5.0 * 16.0 - koerper.breite / 2.0)
	assert_float(koerper.geschwindigkeit.x).is_equal(0.0)
	assert_int(koerper.wand_seite).is_equal(1)
