class_name Trefferzone
extends Area2D
## Die Stelle, an der etwas getroffen werden kann (Hurtbox). Kommt als Kind an jedes Ziel.
## Angriffe rufen treffen() auf; die Trefferzone meldet das Ergebnis per Signal nach oben.
## Die Form kommt als CollisionShape2D-Kind dazu.

signal getroffen(treffer: Treffer)
signal geblockt(treffer: Treffer)

enum Ergebnis { GETROFFEN, GEBLOCKT }

## Kommt ein Angriff mit diesem Skalarprodukt oder kleiner auf den Schild zu, wird er geblockt.
const SCHILD_WINKEL: float = -0.3

## Wohin der Schild zeigt (Einheitsvektor), vom Eltern-Node gesetzt. ZERO = kein Schild.
var schild_richtung: Vector2 = Vector2.ZERO


func _init() -> void:
	# Die Trefferzone wird nur gefunden, sie sucht selbst nichts.
	monitoring = false
	monitorable = true


func treffen(treffer: Treffer) -> Ergebnis:
	if schild_richtung != Vector2.ZERO and treffer.richtung.dot(schild_richtung) <= SCHILD_WINKEL:
		geblockt.emit(treffer)
		return Ergebnis.GEBLOCKT
	getroffen.emit(treffer)
	return Ergebnis.GETROFFEN


## Alle Trefferzonen auf den Ebenen der Maske, die das Rechteck (Weltkoordinaten) berührt.
static func finden(
	welt: World2D, flaeche: Rect2, maske: int, ausser: Array[RID]
) -> Array[Trefferzone]:
	var form := RectangleShape2D.new()
	form.size = flaeche.size
	var abfrage := PhysicsShapeQueryParameters2D.new()
	abfrage.shape = form
	abfrage.transform = Transform2D(0.0, flaeche.get_center())
	abfrage.collide_with_areas = true
	abfrage.collide_with_bodies = false
	abfrage.collision_mask = maske
	abfrage.exclude = ausser
	var zonen: Array[Trefferzone] = []
	for ergebnis: Dictionary in welt.direct_space_state.intersect_shape(abfrage, 32):
		var zone := ergebnis["collider"] as Trefferzone
		if zone != null:
			zonen.append(zone)
	return zonen
