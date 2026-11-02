class_name Testpuppe
extends Koerper
## Übungsziel im Testraum: stirbt mit einem Treffer und kommt nach kurzer Zeit wieder.
## Kann stehen, im Takt nach vorn schlagen oder Geschosse werfen (gerade oder im Bogen).
## Vor jedem Angriff holt sie sichtbar aus (blinkt weiß).

enum Verhalten { STEHT, SCHLAEGT_ZURUECK, WIRFT, WIRFT_BOGEN }

const EBENE_RITTER: int = 0b01
const GESCHOSS_SZENE: PackedScene = preload("res://gemeinsam/geschoss/geschoss.tscn")

@export var verhalten: Verhalten = Verhalten.STEHT
## 1 = schaut nach rechts, -1 = nach links.
@export_range(-1, 1, 2) var blick: int = -1
## Abstand zwischen zwei Angriffen, in s.
@export_range(0.3, 5.0, 0.1) var takt: float = 1.5
## So lange holt sie vor dem Angriff sichtbar aus, in s.
@export_range(0.0, 1.0, 0.05) var ausholen: float = 0.4
## Reichweite des Schlags vom Kasten aus, in px.
@export_range(4.0, 48.0, 1.0) var reichweite: float = 18.0
## So lange bleibt sie tot liegen, in s.
@export_range(0.5, 10.0, 0.5) var wiederkommen: float = 2.0

var tot: bool = false

var _start: Vector2
var _uhr: float = 0.0
var _rest_tot: float = 0.0
var _rest_schlag_anzeige: float = 0.0

@onready var _trefferzone: Trefferzone = $Trefferzone


func _ready() -> void:
	_start = position
	_trefferzone.getroffen.connect(_getroffen)


func _physics_process(delta: float) -> void:
	_rest_schlag_anzeige = maxf(_rest_schlag_anzeige - delta, 0.0)
	if auf_boden:
		geschwindigkeit.x *= maxf(1.0 - 10.0 * delta, 0.0)
	schwerkraft_anwenden(delta)
	bewegen(delta)
	if tot:
		_rest_tot -= delta
		if _rest_tot <= 0.0:
			tot = false
			position = _start
			geschwindigkeit = Vector2.ZERO
			_uhr = 0.0
			_trefferzone.set_deferred("monitorable", true)
			reset_physics_interpolation()
	elif verhalten != Verhalten.STEHT:
		_uhr += delta
		if _uhr >= takt:
			_uhr = 0.0
			_angreifen()
	queue_redraw()


func _angreifen() -> void:
	match verhalten:
		Verhalten.SCHLAEGT_ZURUECK:
			var x := breite / 2.0 if blick > 0 else -breite / 2.0 - reichweite
			var flaeche := Rect2(global_position + Vector2(x, -hoehe), Vector2(reichweite, hoehe))
			var richtung_vektor := Vector2(blick, 0.0)
			var treffer := Treffer.new(
				Treffer.Art.SCHLAG, richtung_vektor, Vector2(blick * 150.0, -100.0), self
			)
			for zone: Trefferzone in Trefferzone.finden(get_world_2d(), flaeche, EBENE_RITTER, []):
				zone.treffen(treffer)
			_rest_schlag_anzeige = 0.1
		Verhalten.WIRFT, Verhalten.WIRFT_BOGEN:
			var geschoss: Geschoss = GESCHOSS_SZENE.instantiate()
			geschoss.gelaende = gelaende
			geschoss.verursacher = self
			geschoss.position = position + Vector2(blick * 8.0, -12.0)
			if verhalten == Verhalten.WIRFT:
				geschoss.geschwindigkeit = Vector2(blick * 140.0, 0.0)
			else:
				geschoss.geschwindigkeit = Vector2(blick * 110.0, -230.0)
				geschoss.schwerkraft = 600.0
			get_parent().add_child(geschoss)


func _getroffen(treffer: Treffer) -> void:
	if tot:
		return
	tot = true
	_rest_tot = wiederkommen
	geschwindigkeit = treffer.rueckstoss + Vector2(0.0, -80.0)
	auf_boden = false
	_trefferzone.set_deferred("monitorable", false)


## Platzhalter: Farbe nach Verhalten, weißes Blinken beim Ausholen.
func _draw() -> void:
	if tot:
		draw_rect(Rect2(-hoehe / 2.0, -6.0, hoehe, 6.0), Color(0.35, 0.3, 0.25))
		return
	var farbe := Color(0.5, 0.6, 0.4)
	match verhalten:
		Verhalten.SCHLAEGT_ZURUECK:
			farbe = Color(0.75, 0.3, 0.3)
		Verhalten.WIRFT, Verhalten.WIRFT_BOGEN:
			farbe = Color(0.6, 0.4, 0.75)
	if verhalten != Verhalten.STEHT and _uhr >= takt - ausholen and int(_uhr * 20.0) % 2 == 0:
		farbe = Color.WHITE
	draw_rect(Rect2(-breite / 2.0, -hoehe, breite, hoehe), farbe)
	draw_rect(Rect2(1.0 if blick > 0 else -5.0, -15.0, 4.0, 2.0), Color(0.1, 0.1, 0.15))
	if _rest_schlag_anzeige > 0.0:
		var x := breite / 2.0 if blick > 0 else -breite / 2.0 - reichweite
		draw_rect(Rect2(x, -hoehe, reichweite, hoehe), Color(1.0, 0.3, 0.3, 0.7))
