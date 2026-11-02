class_name Bumerangaxt
extends Area2D
## Das geworfene Beil: fliegt geradeaus, kehrt um und fliegt zum Werfer zurück.
## Fliegt durch Gegner, zerstört weiche und harte Blöcke; an unzerstörbaren kehrt es um.

## Bitte an die Kamera; der Ritter reicht es weiter.
signal wackeln(staerke: float)

## In px/s.
@export_range(50.0, 600.0, 5.0) var tempo: float = 220.0
## Nach dieser Zeit kehrt die Axt um, in s.
@export_range(0.05, 2.0, 0.01) var umkehr_zeit: float = 0.35
## Faktor auf das Tempo auf dem Rückweg.
@export_range(0.5, 3.0, 0.05) var rueckweg_faktor: float = 1.3
## Rückstoß für getroffene Ziele, in px/s.
@export_range(0.0, 600.0, 10.0) var rueckstoss: float = 150.0

## Vom Werfer gesetzt.
var werfer: Ritter
var gelaende: Gelaende
var richtung: Vector2 = Vector2.RIGHT

var _geschwindigkeit: Vector2 = Vector2.ZERO
var _zeit: float = 0.0
var _kehrt_um: bool = false
var _schon_getroffen: Array[Trefferzone] = []


func _ready() -> void:
	area_entered.connect(_beruehrt)


func _physics_process(delta: float) -> void:
	_zeit += delta
	if _zeit >= umkehr_zeit:
		_kehrt_um = true
	if not is_instance_valid(werfer) or werfer.tot or _zeit > 4.0:
		queue_free()
		return
	if _kehrt_um:
		var zum_werfer := werfer.position + Vector2(0.0, -werfer.hoehe / 2.0) - position
		if zum_werfer.length() < 10.0:
			queue_free()
			return
		_geschwindigkeit = zum_werfer.normalized() * tempo * rueckweg_faktor
	else:
		_geschwindigkeit = richtung * tempo
	position += _geschwindigkeit * delta

	var flaeche := Rect2(position - Vector2(5.0, 5.0), Vector2(10.0, 10.0))
	if not _kehrt_um and gelaende.haelt_stand(flaeche, Gelaende.Haerte.HART):
		_kehrt_um = true
	if gelaende.bloecke_zerstoeren(flaeche, Gelaende.Haerte.HART) > 0:
		wackeln.emit(0.15)
	queue_redraw()


func _beruehrt(bereich: Area2D) -> void:
	var zone := bereich as Trefferzone
	if zone == null or zone in _schon_getroffen:
		return
	_schon_getroffen.append(zone)
	var flug := _geschwindigkeit.normalized()
	var treffer := Treffer.new(Treffer.Art.BUMERANGAXT, flug, flug * rueckstoss, werfer)
	if zone.treffen(treffer) == Trefferzone.Ergebnis.GEBLOCKT:
		_kehrt_um = true
	else:
		wackeln.emit(0.2)


## Platzhalter: drehendes Beil.
func _draw() -> void:
	draw_set_transform(Vector2.ZERO, _zeit * 25.0 * signf(richtung.x))
	draw_rect(Rect2(-1.0, -6.0, 2.0, 12.0), Color(0.55, 0.35, 0.2))
	draw_rect(Rect2(1.0, -6.0, 4.0, 5.0), Color(0.8, 0.82, 0.88))
