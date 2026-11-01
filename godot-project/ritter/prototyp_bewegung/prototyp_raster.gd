extends Node2D
## PROTOTYP – Wegwerf-Code für „Bewegung zum Anfassen“.
## Einfaches Block-Raster: die einzige Wahrheit für die Kollision. Zeichnet sich selbst.

enum Art { LEER, FEST, PLATTFORM }

const BLOCK: int = 16
const FARBE_FEST: Color = Color(0.45, 0.33, 0.24)
const FARBE_FEST_RAND: Color = Color(0.3, 0.21, 0.15)
const FARBE_PLATTFORM: Color = Color(0.75, 0.6, 0.35)

var breite: int = 0
var hoehe: int = 0
var _zellen: PackedByteArray = PackedByteArray()


func anlegen(neue_breite: int, neue_hoehe: int) -> void:
	breite = neue_breite
	hoehe = neue_hoehe
	_zellen.resize(breite * hoehe)
	_zellen.fill(Art.LEER)
	queue_redraw()


func setzen(x: int, y: int, w: int, h: int, art: Art) -> void:
	for zy: int in range(y, y + h):
		for zx: int in range(x, x + w):
			if zx >= 0 and zx < breite and zy >= 0 and zy < hoehe:
				_zellen[zy * breite + zx] = art
	queue_redraw()


## Außerhalb des Rasters gilt alles als fest, damit niemand hinausfällt.
func art_bei(zx: int, zy: int) -> Art:
	if zx < 0 or zx >= breite or zy < 0 or zy >= hoehe:
		return Art.FEST
	return _zellen[zy * breite + zx] as Art


func _draw() -> void:
	for zy: int in range(hoehe):
		for zx: int in range(breite):
			var flaeche := Rect2(zx * BLOCK, zy * BLOCK, BLOCK, BLOCK)
			match art_bei(zx, zy):
				Art.FEST:
					draw_rect(flaeche, FARBE_FEST_RAND)
					draw_rect(flaeche.grow(-1.0), FARBE_FEST)
				Art.PLATTFORM:
					draw_rect(Rect2(flaeche.position, Vector2(BLOCK, 4)), FARBE_PLATTFORM)
