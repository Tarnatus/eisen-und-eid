extends GdUnitTestSuite
## Tests für den Kampf des Ritters im Testraum (Bereich H).
## Säule weich bei Spalte 97, hart bei Spalte 101 (Zeilen 17–19), Boden in Zeile 20.

const SAEULE_WEICH: int = 97
const SAEULE_HART: int = 101

var _runner: GdUnitSceneRunner
var _ritter: Ritter
var _gelaende: Gelaende


func before_test() -> void:
	_runner = scene_runner("res://ritter/testraum/testraum.tscn")
	_ritter = _runner.scene().get_node("Ritter")
	_gelaende = _runner.scene().get_node("Gelaende")


func after_test() -> void:
	Engine.time_scale = 1.0


## Stellt den Ritter mit 4 px Abstand links vor die Säule, Blick nach rechts.
func _vor_saeule(spalte: int) -> void:
	_ritter.zuruecksetzen(Vector2(spalte * 16.0 - _ritter.breite / 2.0 - 4.0, 320.0))
	_ritter.blick = 1
	await _bilder(5)


func _bilder(anzahl: int) -> void:
	for i: int in range(anzahl):
		await get_tree().physics_frame


func _tippen(aktion: String) -> void:
	_runner.simulate_action_press(aktion)
	await _bilder(2)
	_runner.simulate_action_release(aktion)
	await _bilder(2)


func test_schlag_bricht_weichen_block() -> void:
	await _vor_saeule(SAEULE_WEICH)
	await _tippen("angreifen")
	assert_int(_gelaende.art_bei(SAEULE_WEICH, 19)).is_equal(Gelaende.Art.LEER)


func test_schlag_bricht_keinen_harten_block() -> void:
	await _vor_saeule(SAEULE_HART)
	await _tippen("angreifen")
	assert_int(_gelaende.art_bei(SAEULE_HART, 19)).is_equal(Gelaende.Art.FEST)


func test_powerschlag_bricht_harten_block() -> void:
	await _vor_saeule(SAEULE_HART)
	_runner.simulate_action_press("angreifen")
	await _bilder(int(_ritter.powerschlag_ladezeit * 60.0) + 6)
	_runner.simulate_action_release("angreifen")
	await _bilder(3)
	assert_int(_gelaende.art_bei(SAEULE_HART, 19)).is_equal(Gelaende.Art.LEER)


func test_bumerangaxt_verbraucht_eine_ladung_und_nur_eine_fliegt() -> void:
	await _bilder(3)
	await _tippen("bumerangaxt")
	await _tippen("bumerangaxt")
	assert_int(_ritter.ladungen).is_equal(_ritter.ladungen_start - 1)


func test_ein_treffer_toetet() -> void:
	await _bilder(3)
	var zone: Trefferzone = _ritter.get_node("Trefferzone")
	zone.treffen(Treffer.new(Treffer.Art.SCHLAG, Vector2.LEFT, Vector2.ZERO, auto_free(Node.new())))
	assert_bool(_ritter.tot).is_true()


func test_schild_haelt_treffer_von_vorn_ab() -> void:
	await _bilder(3)
	_ritter.blick = 1
	_runner.simulate_action_press("schild")
	await _bilder(2)
	var zone: Trefferzone = _ritter.get_node("Trefferzone")
	var treffer := Treffer.new(
		Treffer.Art.SCHLAG, Vector2.LEFT, Vector2.ZERO, auto_free(Node.new())
	)
	assert_int(zone.treffen(treffer)).is_equal(Trefferzone.Ergebnis.GEBLOCKT)
	assert_bool(_ritter.tot).is_false()
	_runner.simulate_action_release("schild")


func test_mitspieler_stirbt_nicht() -> void:
	await _bilder(3)
	var zone: Trefferzone = _ritter.get_node("Trefferzone")
	var mitspieler: Ritter = auto_free(Ritter.new())
	zone.treffen(
		Treffer.new(Treffer.Art.POWERSCHLAG, Vector2.LEFT, Vector2(-200, -100), mitspieler)
	)
	assert_bool(_ritter.tot).is_false()
	assert_float(_ritter.geschwindigkeit.x).is_less(0.0)
