extends GdUnitTestSuite
## Tests für Härte und Zerstörung im Block-Raster.

const HART: Vector2i = Vector2i(0, 0)
const PLATTFORM: Vector2i = Vector2i(1, 0)
const WEICH: Vector2i = Vector2i(2, 0)
const UNZERSTOERBAR: Vector2i = Vector2i(3, 0)


func _gelaende() -> Gelaende:
	var gelaende: Gelaende = (load("res://gelaende/gelaende.tscn") as PackedScene).instantiate()
	var bloecke: TileMapLayer = gelaende.get_node("Bloecke")
	bloecke.set_cell(Vector2i(0, 0), 0, HART)
	bloecke.set_cell(Vector2i(1, 0), 0, WEICH)
	bloecke.set_cell(Vector2i(2, 0), 0, UNZERSTOERBAR)
	bloecke.set_cell(Vector2i(3, 0), 0, PLATTFORM)
	add_child(gelaende)
	auto_free(gelaende)
	return gelaende


func test_haerte_wird_eingelesen() -> void:
	var gelaende := _gelaende()
	assert_int(gelaende.haerte_bei(0, 0)).is_equal(Gelaende.Haerte.HART)
	assert_int(gelaende.haerte_bei(1, 0)).is_equal(Gelaende.Haerte.WEICH)
	assert_int(gelaende.haerte_bei(2, 0)).is_equal(Gelaende.Haerte.UNZERSTOERBAR)
	assert_int(gelaende.haerte_bei(3, 0)).is_equal(Gelaende.Haerte.WEICH)
	assert_int(gelaende.haerte_bei(-5, 0)).is_equal(Gelaende.Haerte.UNZERSTOERBAR)


func test_schlag_bricht_nur_weiche_bloecke() -> void:
	var gelaende := _gelaende()
	assert_bool(gelaende.block_zerstoeren(Vector2i(0, 0), Gelaende.Haerte.WEICH)).is_false()
	assert_bool(gelaende.block_zerstoeren(Vector2i(1, 0), Gelaende.Haerte.WEICH)).is_true()
	assert_bool(gelaende.block_zerstoeren(Vector2i(3, 0), Gelaende.Haerte.WEICH)).is_true()
	assert_int(gelaende.art_bei(1, 0)).is_equal(Gelaende.Art.LEER)
	assert_int(gelaende.art_bei(0, 0)).is_equal(Gelaende.Art.FEST)


func test_powerschlag_bricht_harte_aber_nie_unzerstoerbare() -> void:
	var gelaende := _gelaende()
	assert_bool(gelaende.block_zerstoeren(Vector2i(0, 0), Gelaende.Haerte.HART)).is_true()
	assert_bool(gelaende.block_zerstoeren(Vector2i(2, 0), Gelaende.Haerte.HART)).is_false()
	assert_bool(gelaende.block_zerstoeren(Vector2i(-1, 0), Gelaende.Haerte.HART)).is_false()


func test_rechteck_zerstoert_und_meldet() -> void:
	var gelaende := _gelaende()
	var gemeldet: Array[Vector2i] = []
	gelaende.block_zerstoert.connect(func(zelle: Vector2i) -> void: gemeldet.append(zelle))
	var anzahl := gelaende.bloecke_zerstoeren(Rect2(0.0, 0.0, 64.0, 16.0), Gelaende.Haerte.HART)
	assert_int(anzahl).is_equal(3)
	assert_array(gemeldet).contains_exactly([Vector2i(0, 0), Vector2i(1, 0), Vector2i(3, 0)])


func test_wiederherstellen_holt_bloecke_zurueck() -> void:
	var gelaende := _gelaende()
	gelaende.block_zerstoeren(Vector2i(1, 0), Gelaende.Haerte.WEICH)
	gelaende.wiederherstellen()
	assert_int(gelaende.art_bei(1, 0)).is_equal(Gelaende.Art.FEST)
