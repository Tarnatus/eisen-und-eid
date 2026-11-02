class_name Geschoss
extends Area2D
## Ein geworfenes oder geschossenes Ding (Testpuppe, später Pfeile und Katapultsteine).
## Fliegt gerade oder im Bogen, verschwindet an festen Blöcken und trifft Trefferzonen.
## Prallt von einem Schild ab und trifft danach nichts mehr.

## Wird vom Werfer gesetzt.
var gelaende: Gelaende
var verursacher: Node
## In px/s.
var geschwindigkeit: Vector2 = Vector2.ZERO
## In px/s²; 0 = fliegt gerade.
var schwerkraft: float = 0.0

var _lebenszeit: float = 4.0
var _abgeprallt: bool = false


func _ready() -> void:
	area_entered.connect(_beruehrt)


func _physics_process(delta: float) -> void:
	_lebenszeit -= delta
	geschwindigkeit.y += schwerkraft * delta
	position += geschwindigkeit * delta
	var zelle := Vector2i((position / Gelaende.BLOCK).floor())
	if _lebenszeit <= 0.0 or gelaende.art_bei(zelle.x, zelle.y) == Gelaende.Art.FEST:
		queue_free()
	queue_redraw()


func _beruehrt(bereich: Area2D) -> void:
	var zone := bereich as Trefferzone
	if zone == null or _abgeprallt:
		return
	var treffer := Treffer.new(
		Treffer.Art.GESCHOSS, geschwindigkeit.normalized(), geschwindigkeit * 0.3, verursacher
	)
	if zone.treffen(treffer) == Trefferzone.Ergebnis.GEBLOCKT:
		_abgeprallt = true
		geschwindigkeit = Vector2(-geschwindigkeit.x * 0.4, -120.0)
		schwerkraft = 600.0
		set_deferred("collision_mask", 0)
	else:
		queue_free()


## Platzhalter: kleiner Stein.
func _draw() -> void:
	draw_rect(Rect2(-2.0, -2.0, 4.0, 4.0), Color(0.9, 0.3, 0.25) if not _abgeprallt else Color.GRAY)
