class_name Kamera
extends Camera2D
## Kamera mit Wackeln nach dem Trauma-Modell: wackeln() addiert Trauma, es klingt ab,
## die Auslenkung wächst mit dem Quadrat des Traumas. Ganze Pixel, passend zur Pixelgrafik.

## Größte Auslenkung in px bei vollem Trauma.
@export_range(0.0, 20.0, 0.5) var max_versatz: float = 6.0
## So viel Trauma klingt pro Sekunde ab.
@export_range(0.1, 10.0, 0.1) var abklingen: float = 2.0

var _trauma: float = 0.0


## Stärke von 0 bis 1; mehrere Auslöser addieren sich.
func wackeln(staerke: float) -> void:
	_trauma = minf(_trauma + staerke, 1.0)


func _process(delta: float) -> void:
	_trauma = maxf(_trauma - abklingen * delta, 0.0)
	var auslenkung := _trauma * _trauma * max_versatz
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * auslenkung
	offset = offset.round()
