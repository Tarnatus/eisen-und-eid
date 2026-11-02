extends GdUnitTestSuite
## Tests für den Ritter im Testraum: Sprunghöhe mit den Broforce-Werten.


## Springt im Testraum und gibt die erreichte Höhe in px zurück.
func _sprunghoehe(halten_bilder: int) -> float:
	var runner := scene_runner("res://ritter/testraum/testraum.tscn")
	var ritter: Ritter = runner.scene().get_node("Ritter")
	for i: int in range(10):
		await get_tree().physics_frame
	var boden := ritter.position.y
	var hoechster := boden
	runner.simulate_action_press("springen")
	for i: int in range(60):
		if i == halten_bilder:
			runner.simulate_action_release("springen")
		await get_tree().physics_frame
		hoechster = minf(hoechster, ritter.position.y)
	runner.simulate_action_release("springen")
	return boden - hoechster


func test_voller_sprung_knapp_vier_bloecke() -> void:
	# 260 px/s × 0,123 s Steigen plus 260² / (2 × 1100) Flug = rund 63 px.
	var hoehe: float = await _sprunghoehe(30)
	assert_float(hoehe).is_between(56.0, 68.0)


func test_kurzer_sprung_niedriger() -> void:
	var hoehe: float = await _sprunghoehe(1)
	assert_float(hoehe).is_between(25.0, 45.0)
