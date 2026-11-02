extends Node2D
## Testraum zum Ausprobieren von Bewegung und Kampf. Gelände ist in der TileMapLayer gemalt;
## im Editor frei weiter zu bemalen. Bereiche wie im Prototyp „Bewegung zum Anfassen“:
## A Plattformen, B Säulen 1–5 Blöcke, C Gruben 3/5/7, D Kletterwand, E Schacht,
## F niedriger Gang, G Plattform-Turm. Rechts davon H Kampf: Decke, Säulen und Bodenfelder
## in den Härten weich (Holz), hart (Stein), unzerstörbar (dunkel) und vier Testpuppen.

## Start im Kampfbereich H; die Bewegungsbereiche liegen links davon.
const START_ZELLE: Vector2i = Vector2i(95, 20)
const HINWEIS: String = "R/Select: Neustart  F Schlag (halten: Power)  G Schild  H Axt: %d"

@onready var _gelaende: Gelaende = $Gelaende
@onready var _ritter: Ritter = $Ritter
@onready var _kamera: Kamera = $Kamera
@onready var _hinweis: Label = $Anzeige/Hinweis


func _ready() -> void:
	var flaeche := Rect2i(_gelaende.ursprung, Vector2i(_gelaende.breite, _gelaende.hoehe))
	_kamera.limit_left = flaeche.position.x * Gelaende.BLOCK
	_kamera.limit_top = flaeche.position.y * Gelaende.BLOCK
	_kamera.limit_right = flaeche.end.x * Gelaende.BLOCK
	_kamera.limit_bottom = flaeche.end.y * Gelaende.BLOCK
	_ritter.wackeln.connect(_kamera.wackeln)
	_ritter.ladungen_geaendert.connect(_ladungen_zeigen)
	_ritter.gestorben.connect(_nach_tod)
	_neustart()


func _neustart() -> void:
	Engine.time_scale = 1.0
	_gelaende.wiederherstellen()
	_ritter.zuruecksetzen(Vector2(START_ZELLE * Gelaende.BLOCK) + Vector2(8.0, 0.0))
	_kamera.position = _ritter.position.round()
	_kamera.reset_physics_interpolation()


func _nach_tod() -> void:
	await get_tree().create_timer(1.0).timeout
	if _ritter.tot:
		_neustart()


func _ladungen_zeigen(anzahl: int) -> void:
	_hinweis.text = HINWEIS % anzahl


func _unhandled_input(event: InputEvent) -> void:
	var taste := event as InputEventKey
	if taste != null and taste.pressed and not taste.echo and taste.keycode == KEY_R:
		_neustart()
	var knopf := event as InputEventJoypadButton
	if knopf != null and knopf.pressed and knopf.button_index == JOY_BUTTON_BACK:
		_neustart()


func _physics_process(_delta: float) -> void:
	# Kamera im Physik-Takt auf ganze Pixel; die Interpolation glättet sie wie den Ritter.
	_kamera.position = _ritter.position.round()
