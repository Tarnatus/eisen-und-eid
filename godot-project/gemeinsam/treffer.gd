class_name Treffer
extends RefCounted
## Was ein Angriff beim Ziel abliefert. Das Ziel entscheidet selbst, was er bewirkt.

enum Art { SCHLAG, POWERSCHLAG, BUMERANGAXT, GESCHOSS }

var art: Art
## Flugrichtung des Angriffs (Einheitsvektor), vom Angreifer zum Ziel.
var richtung: Vector2
## Geschwindigkeit in px/s, die das Ziel beim Zurückwerfen bekommt.
var rueckstoss: Vector2
var verursacher: Node


func _init(
	neue_art: Art, neue_richtung: Vector2, neuer_rueckstoss: Vector2, neuer_verursacher: Node
) -> void:
	art = neue_art
	richtung = neue_richtung
	rueckstoss = neuer_rueckstoss
	verursacher = neuer_verursacher
