extends GdUnitTestSuite
## Tests für den Schild in der Trefferzone.


func _treffer(richtung: Vector2) -> Treffer:
	return Treffer.new(Treffer.Art.SCHLAG, richtung, Vector2.ZERO, null)


func test_ohne_schild_getroffen() -> void:
	var zone: Trefferzone = auto_free(Trefferzone.new())
	var gemeldet: Array[Treffer] = []
	zone.getroffen.connect(func(treffer: Treffer) -> void: gemeldet.append(treffer))
	var ergebnis := zone.treffen(_treffer(Vector2.LEFT))
	assert_int(ergebnis).is_equal(Trefferzone.Ergebnis.GETROFFEN)
	assert_int(gemeldet.size()).is_equal(1)


func test_schild_vorn_blockt_von_vorn() -> void:
	var zone: Trefferzone = auto_free(Trefferzone.new())
	zone.schild_richtung = Vector2.RIGHT
	# Angriff kommt von rechts, fliegt also nach links.
	assert_int(zone.treffen(_treffer(Vector2.LEFT))).is_equal(Trefferzone.Ergebnis.GEBLOCKT)


func test_schild_vorn_blockt_nicht_von_hinten() -> void:
	var zone: Trefferzone = auto_free(Trefferzone.new())
	zone.schild_richtung = Vector2.RIGHT
	assert_int(zone.treffen(_treffer(Vector2.RIGHT))).is_equal(Trefferzone.Ergebnis.GETROFFEN)


func test_schild_oben_blockt_bogenschuss_von_oben() -> void:
	var zone: Trefferzone = auto_free(Trefferzone.new())
	zone.schild_richtung = Vector2.UP
	var schraeg_von_oben := Vector2(-0.5, 0.8).normalized()
	assert_int(zone.treffen(_treffer(schraeg_von_oben))).is_equal(Trefferzone.Ergebnis.GEBLOCKT)
	assert_int(zone.treffen(_treffer(Vector2.LEFT))).is_equal(Trefferzone.Ergebnis.GETROFFEN)
