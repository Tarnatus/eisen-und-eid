class_name Koerper
extends Node2D
## Gemeinsamer Bewegungs-Baustein: ein Kasten (AABB) gegen das Block-Raster (siehe ADR 0001).
## Erst X, dann Y; danach werden Boden, Wand und Decke erkannt.
## Die Position des Nodes ist die Mitte der Füße (unten Mitte des Kastens).
## Unterklassen setzen geschwindigkeit, rufen schwerkraft_anwenden() und bewegen() auf.

const EPSILON: float = 0.001
const BLOCK: float = Gelaende.BLOCK

## Das Gelände, gegen das sich der Körper bewegt.
@export var gelaende: Gelaende

@export_group("Körper")
## Breite des Kastens in px.
@export var breite: float = 12.0
## Höhe des Kastens in px.
@export var hoehe: float = 18.0
## Schwerkraft in px/s².
@export_range(200.0, 3000.0, 10.0) var schwerkraft: float = 1100.0
## Höchste Fallgeschwindigkeit in px/s.
@export_range(100.0, 1000.0, 10.0) var max_fall: float = 400.0

var geschwindigkeit: Vector2 = Vector2.ZERO
## Gewollte Bewegungsrichtung (-1, 0, 1), von der Steuerung gesetzt.
var richtung: int = 0
var auf_boden: bool = false
## -1 Wand links, 1 Wand rechts, 0 keine Wand.
var wand_seite: int = 0
## Im letzten bewegen() an die Decke gestoßen.
var an_decke: bool = false

var _rest_durchfallen: float = 0.0


func schwerkraft_anwenden(delta: float) -> void:
	geschwindigkeit.y = minf(geschwindigkeit.y + schwerkraft * delta, max_fall)


## Bewegt den Kasten um geschwindigkeit × delta und prüft danach Boden und Wand.
func bewegen(delta: float) -> void:
	_rest_durchfallen = maxf(_rest_durchfallen - delta, 0.0)
	an_decke = false
	_bewegen_x(geschwindigkeit.x * delta)
	_bewegen_y(geschwindigkeit.y * delta)
	_beruehrungen_pruefen()


## Für die angegebene Zeit tragen Plattformen nicht.
func durch_plattformen_fallen(dauer: float) -> void:
	_rest_durchfallen = dauer
	auf_boden = false


func steht_nur_auf_plattform() -> bool:
	var zeile := floori((position.y + EPSILON) / BLOCK)
	for spalte: int in range(_spalte_links(), _spalte_rechts() + 1):
		if gelaende.art_bei(spalte, zeile) == Gelaende.Art.FEST:
			return false
	return true


## Kopf über der Wand frei, Füße noch an der Wand: die Oberkante ist erreicht.
func kante_erreicht(seite: int) -> bool:
	var spalte := floori((position.x + seite * (breite / 2.0 + 0.01)) / BLOCK)
	var kopf := floori((position.y - hoehe + 1.0) / BLOCK)
	var fuesse := floori((position.y - 1.0) / BLOCK)
	return (
		gelaende.art_bei(spalte, kopf) != Gelaende.Art.FEST
		and gelaende.art_bei(spalte, fuesse) == Gelaende.Art.FEST
	)


func _bewegen_x(dx: float) -> void:
	if dx == 0.0:
		return
	var neu := position.x + dx
	var zeile_von := floori((position.y - hoehe) / BLOCK)
	var zeile_bis := floori((position.y - EPSILON) / BLOCK)
	# Alle Spalten prüfen, in die die Kante neu eintaucht, damit nichts durch Wände rutscht.
	if dx > 0.0:
		var kante_alt := _spalte_rechts()
		var kante_neu := floori((neu + breite / 2.0 - EPSILON) / BLOCK)
		for spalte: int in range(kante_alt + 1, kante_neu + 1):
			if _spalte_fest(spalte, zeile_von, zeile_bis):
				neu = spalte * BLOCK - breite / 2.0
				geschwindigkeit.x = 0.0
				break
	else:
		var kante_alt := _spalte_links()
		var kante_neu := floori((neu - breite / 2.0) / BLOCK)
		for spalte: int in range(kante_alt - 1, kante_neu - 1, -1):
			if _spalte_fest(spalte, zeile_von, zeile_bis):
				neu = (spalte + 1) * BLOCK + breite / 2.0
				geschwindigkeit.x = 0.0
				break
	position.x = neu


func _bewegen_y(dy: float) -> void:
	if dy == 0.0:
		return
	var neu := position.y + dy
	if dy > 0.0:
		# Nur Zeilen prüfen, in die die Füße neu eintauchen: so trägt eine Plattform nur von oben.
		var zeile_alt := floori((position.y - EPSILON) / BLOCK)
		var zeile_neu := floori((neu - EPSILON) / BLOCK)
		for zeile: int in range(zeile_alt + 1, zeile_neu + 1):
			if _zeile_traegt(zeile):
				neu = zeile * BLOCK
				geschwindigkeit.y = 0.0
				break
	else:
		var kopf_alt := floori((position.y - hoehe) / BLOCK)
		var kopf_neu := floori((neu - hoehe) / BLOCK)
		# Alle Zeilen prüfen, in die der Kopf neu eintaucht, damit er nicht durch Decken springt.
		for zeile: int in range(kopf_alt - 1, kopf_neu - 1, -1):
			if _zeile_fest(zeile):
				neu = (zeile + 1) * BLOCK + hoehe
				geschwindigkeit.y = 0.0
				an_decke = true
				break
	position.y = neu


func _beruehrungen_pruefen() -> void:
	var zeile_unter := floori((position.y + EPSILON) / BLOCK)
	var genau_auf_kante := absf(position.y - zeile_unter * BLOCK) < 0.01
	auf_boden = geschwindigkeit.y >= 0.0 and genau_auf_kante and _zeile_traegt(zeile_unter)

	var zeile_von := floori((position.y - hoehe) / BLOCK)
	var zeile_bis := floori((position.y - EPSILON) / BLOCK)
	var rechts := floori((position.x + breite / 2.0 + 0.01) / BLOCK)
	var links := floori((position.x - breite / 2.0 - 0.01) / BLOCK)
	var wand_rechts := _spalte_fest(rechts, zeile_von, zeile_bis)
	var wand_links := _spalte_fest(links, zeile_von, zeile_bis)
	# Wände auf beiden Seiten (Schacht): die gewollte Richtung gewinnt.
	if wand_rechts and (not wand_links or richtung >= 0):
		wand_seite = 1
	elif wand_links:
		wand_seite = -1
	else:
		wand_seite = 0


func _spalte_links() -> int:
	return floori((position.x - breite / 2.0) / BLOCK)


func _spalte_rechts() -> int:
	return floori((position.x + breite / 2.0 - EPSILON) / BLOCK)


func _spalte_fest(spalte: int, zeile_von: int, zeile_bis: int) -> bool:
	for zeile: int in range(zeile_von, zeile_bis + 1):
		if gelaende.art_bei(spalte, zeile) == Gelaende.Art.FEST:
			return true
	return false


func _zeile_fest(zeile: int) -> bool:
	for spalte: int in range(_spalte_links(), _spalte_rechts() + 1):
		if gelaende.art_bei(spalte, zeile) == Gelaende.Art.FEST:
			return true
	return false


func _zeile_traegt(zeile: int) -> bool:
	for spalte: int in range(_spalte_links(), _spalte_rechts() + 1):
		var art := gelaende.art_bei(spalte, zeile)
		if art == Gelaende.Art.FEST:
			return true
		if art == Gelaende.Art.PLATTFORM and _rest_durchfallen <= 0.0:
			return true
	return false
