extends Node2D
## PROTOTYP – Wegwerf-Code für „Bewegung zum Anfassen“.
## Die Bewegung des Ritters: ein Kasten (AABB) gegen das Block-Raster, erst X, dann Y.
## Dieses Skript ist der Teil, der später sauber in den echten Ritter übernommen wird.
## Es kennt weder Testraum noch Anzeige; die lesen nur von hier.
## Die Position des Nodes ist die Mitte der Füße (unten Mitte des Kastens).
## Startwerte: Recherche „Wie fühlt sich Broforce-Bewegung an?“
## (B = belegt, D = Docs, S = geschätzt).

const Raster := preload("res://ritter/prototyp_bewegung/prototyp_raster.gd")

const BREITE: float = 12.0
const HOEHE: float = 18.0
const EPSILON: float = 0.001
const BLOCK: float = 16.0

@export_group("Laufen")
## Höchstgeschwindigkeit beim Laufen in px/s. Broforce: 110 (D, B).
@export_range(40.0, 300.0, 1.0) var lauf_tempo: float = 110.0
## Geschwindigkeit, auf die ein Tastendruck sofort springt, in px/s. Broforce: 25 (B).
@export_range(0.0, 150.0, 1.0) var anschub: float = 25.0
## Beschleunigung bis zur Höchstgeschwindigkeit in px/s². Broforce: 220 (D).
@export_range(0.0, 2000.0, 10.0) var beschleunigung: float = 220.0
## Zusätzliche Beschleunigung unter 50 px/s in px/s². Broforce: 286 (B, D).
@export_range(0.0, 2000.0, 10.0) var extra_beschleunigung_langsam: float = 286.0
## Faktor auf die Höchstgeschwindigkeit beim Sprinten. Broforce: 1,5 (B).
@export_range(1.0, 3.0, 0.05) var sprint_faktor: float = 1.5
## Bremsen am Boden ohne Eingabe, pro Sekunde (v *= 1 − Wert × dt). Broforce: 10–25 (D, S).
@export_range(0.0, 60.0, 0.5) var bremsen_boden: float = 20.0
## Bremsen in der Luft ohne Eingabe, pro Sekunde. Broforce: 0 (D).
@export_range(0.0, 60.0, 0.5) var bremsen_luft: float = 0.0

@export_group("Sprung")
## Schwerkraft in px/s². Broforce: 1100 (D, B).
@export_range(200.0, 3000.0, 10.0) var schwerkraft: float = 1100.0
## Steiggeschwindigkeit beim Sprung in px/s, konstant während der Haltezeit. Broforce: 260 (B).
@export_range(50.0, 600.0, 5.0) var sprung_tempo: float = 260.0
## So lange bleibt die Steiggeschwindigkeit, solange die Taste gehalten wird, in s. Broforce: 0,123.
@export_range(0.0, 0.5, 0.005) var halte_zeit: float = 0.123
## Höchste Fallgeschwindigkeit in px/s. Broforce: 400 (D).
@export_range(100.0, 1000.0, 10.0) var max_fall: float = 400.0
## Ein zu früh gedrückter Sprung wird so lange gemerkt, in s. Broforce: 0,2 (B).
@export_range(0.0, 0.5, 0.01) var jump_buffer: float = 0.2
## So lange nach dem Verlassen einer Kante darf man noch springen, in s. Broforce: ~0,08 (S).
@export_range(0.0, 0.3, 0.01) var coyote_zeit: float = 0.08
## Mindestabstand zwischen zwei Sprüngen vom Boden, in s. Broforce: 0,08 (B).
@export_range(0.0, 0.5, 0.01) var sprung_abstand: float = 0.08

@export_group("Wand")
## Höchste Rutschgeschwindigkeit an der Wand in px/s. Broforce: 40 (D).
@export_range(0.0, 400.0, 5.0) var wand_rutschen: float = 40.0
## So lange klebt man nach dem Loslassen der Richtung noch an der Wand, in s. Broforce: 0,2.
@export_range(0.0, 1.0, 0.01) var wand_klebezeit: float = 0.2
## Senkrechter Hüpfer an der Wand in px/s, ohne Haltezeit. Broforce: 260 (B).
@export_range(0.0, 600.0, 5.0) var wand_hopser_tempo: float = 260.0
## Mindestabstand zwischen zwei Wand-Hüpfern in s. Broforce: 0,2 (D).
@export_range(0.0, 0.5, 0.01) var wand_hopser_abstand: float = 0.2
## Kanten-Flip: Erreicht der Kopf beim Hochklettern die Oberkante, schwingt sich der Ritter hinauf.
@export var kanten_flip: bool = true
## Schwung nach oben beim Kanten-Flip in px/s.
@export_range(0.0, 500.0, 5.0) var kanten_flip_hoch: float = 220.0
## Schwung zur Seite beim Kanten-Flip in px/s. Broforce: 100 (D, B).
@export_range(0.0, 300.0, 5.0) var kanten_flip_seitlich: float = 100.0
## Dauer des Kanten-Flips in s. Broforce: 11 Animationsbilder (S: ~0,18).
@export_range(0.0, 0.5, 0.01) var kanten_flip_dauer: float = 0.18

@export_group("Plattform")
## So lange fällt man nach „unten + Sprung“ durch Plattform-Blöcke, in s.
@export_range(0.0, 0.5, 0.01) var durchfallen_zeit: float = 0.15

# Wird vom Testraum gesetzt (call down).
var raster: Raster

# Zustand, nur zum Lesen für Anzeige und Testraum.
var geschwindigkeit: Vector2 = Vector2.ZERO
var richtung: int = 0
var blick: int = 1
var auf_boden: bool = false
var wand_seite: int = 0
var an_decke: bool = false
var zustand: String = "Boden"
var rest_halten: float = 0.0
var rest_coyote: float = 0.0
var rest_buffer: float = 0.0
var rest_wand_kleben: float = 0.0
var rest_flip: float = 0.0
var rest_durchfallen: float = 0.0
var letzte_flughoehe: float = 0.0
var letzte_flugweite: float = 0.0

var _rest_sprung_abstand: float = 0.0
var _rest_wand_abstand: float = 0.0
var _flip_richtung: int = 0
var _flug_start: Vector2 = Vector2.ZERO
var _flug_hoechster_punkt: float = 0.0


func zuruecksetzen(fuesse: Vector2) -> void:
	position = fuesse
	geschwindigkeit = Vector2.ZERO
	rest_halten = 0.0
	rest_buffer = 0.0
	rest_flip = 0.0
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	if raster == null:
		return
	var war_am_boden := auf_boden

	var achse := Input.get_axis("links", "rechts")
	richtung = 0 if absf(achse) < 0.5 else int(signf(achse))
	if richtung != 0:
		blick = richtung
	var sprint := Input.is_action_pressed("sprinten")
	var sprung_gedrueckt := Input.is_action_just_pressed("springen")
	var sprung_gehalten := Input.is_action_pressed("springen")
	var unten_gehalten := Input.is_action_pressed("unten")

	rest_halten = maxf(rest_halten - delta, 0.0)
	rest_coyote = maxf(rest_coyote - delta, 0.0)
	rest_buffer = maxf(rest_buffer - delta, 0.0)
	rest_wand_kleben = maxf(rest_wand_kleben - delta, 0.0)
	rest_flip = maxf(rest_flip - delta, 0.0)
	rest_durchfallen = maxf(rest_durchfallen - delta, 0.0)
	_rest_sprung_abstand = maxf(_rest_sprung_abstand - delta, 0.0)
	_rest_wand_abstand = maxf(_rest_wand_abstand - delta, 0.0)

	if sprung_gedrueckt:
		rest_buffer = jump_buffer
	if auf_boden:
		rest_coyote = coyote_zeit
	if wand_seite != 0 and richtung == wand_seite:
		rest_wand_kleben = wand_klebezeit
	var klebt_an_wand := not auf_boden and wand_seite != 0 and rest_wand_kleben > 0.0

	# Waagerecht: sofortiger Anschub, dann Beschleunigung; ohne Eingabe bremsen.
	if rest_flip > 0.0:
		geschwindigkeit.x = _flip_richtung * kanten_flip_seitlich
	elif richtung != 0:
		var hoechst := lauf_tempo * (sprint_faktor if sprint else 1.0)
		if signf(geschwindigkeit.x) != richtung or absf(geschwindigkeit.x) < anschub:
			geschwindigkeit.x = richtung * anschub
		var beschl := beschleunigung
		if absf(geschwindigkeit.x) < 50.0:
			beschl += extra_beschleunigung_langsam
		if absf(geschwindigkeit.x) < hoechst:
			geschwindigkeit.x = move_toward(geschwindigkeit.x, richtung * hoechst, beschl * delta)
		elif auf_boden:
			# Schneller als erlaubt (z. B. Sprint losgelassen): sanft auf Laufgeschwindigkeit.
			var gebremst := absf(geschwindigkeit.x) * maxf(1.0 - bremsen_boden * delta, 0.0)
			geschwindigkeit.x = richtung * maxf(hoechst, gebremst)
	else:
		var rate := bremsen_boden if auf_boden else bremsen_luft
		geschwindigkeit.x *= maxf(1.0 - rate * delta, 0.0)
		if absf(geschwindigkeit.x) < 2.0:
			geschwindigkeit.x = 0.0

	# Senkrecht: durch Plattform fallen, Sprung, Wand-Hüpfer, Halten, Schwerkraft.
	if auf_boden and unten_gehalten and rest_buffer > 0.0 and _steht_nur_auf_plattform():
		rest_durchfallen = durchfallen_zeit
		rest_buffer = 0.0
		rest_coyote = 0.0
		auf_boden = false
	elif rest_buffer > 0.0 and rest_coyote > 0.0 and _rest_sprung_abstand <= 0.0:
		geschwindigkeit.y = -sprung_tempo
		rest_halten = halte_zeit
		rest_buffer = 0.0
		rest_coyote = 0.0
		_rest_sprung_abstand = sprung_abstand
		auf_boden = false
	elif (
		sprung_gedrueckt
		and klebt_an_wand
		and geschwindigkeit.y > -25.0
		and _rest_wand_abstand <= 0.0
	):
		geschwindigkeit.y = -wand_hopser_tempo
		geschwindigkeit.x = 0.0
		rest_halten = 0.0
		rest_buffer = 0.0
		_rest_wand_abstand = wand_hopser_abstand

	if rest_halten > 0.0:
		if sprung_gehalten:
			geschwindigkeit.y = -sprung_tempo
		else:
			rest_halten = 0.0
	if rest_halten <= 0.0:
		geschwindigkeit.y += schwerkraft * delta
	geschwindigkeit.y = minf(geschwindigkeit.y, max_fall)
	if klebt_an_wand and geschwindigkeit.y > wand_rutschen:
		geschwindigkeit.y = wand_rutschen

	if (
		kanten_flip
		and rest_flip <= 0.0
		and not auf_boden
		and wand_seite != 0
		and richtung == wand_seite
		and geschwindigkeit.y < 0.0
		and _kante_erreicht(wand_seite)
	):
		rest_flip = kanten_flip_dauer
		_flip_richtung = wand_seite
		geschwindigkeit.y = -kanten_flip_hoch
		rest_halten = 0.0

	an_decke = false
	_bewegen_x(geschwindigkeit.x * delta)
	_bewegen_y(geschwindigkeit.y * delta)
	_beruehrungen_pruefen()

	# Flug vermessen: Höhe und Weite vom Abheben bis zur Landung.
	if war_am_boden and not auf_boden:
		_flug_start = position
		_flug_hoechster_punkt = position.y
	elif not auf_boden:
		_flug_hoechster_punkt = minf(_flug_hoechster_punkt, position.y)
	elif not war_am_boden:
		letzte_flughoehe = _flug_start.y - _flug_hoechster_punkt
		letzte_flugweite = absf(position.x - _flug_start.x)

	if rest_flip > 0.0:
		zustand = "Kanten-Flip"
	elif auf_boden:
		zustand = "Boden"
	elif klebt_an_wand:
		zustand = "Wand"
	elif geschwindigkeit.y < 0.0:
		zustand = "Steigen"
	else:
		zustand = "Fallen"
	queue_redraw()


func _bewegen_x(dx: float) -> void:
	if dx == 0.0:
		return
	var neu := position.x + dx
	var zeile_von := floori((position.y - HOEHE) / BLOCK)
	var zeile_bis := floori((position.y - EPSILON) / BLOCK)
	if dx > 0.0:
		var spalte := floori((neu + BREITE / 2.0 - EPSILON) / BLOCK)
		if _spalte_fest(spalte, zeile_von, zeile_bis):
			neu = spalte * BLOCK - BREITE / 2.0
			geschwindigkeit.x = 0.0
	else:
		var spalte := floori((neu - BREITE / 2.0) / BLOCK)
		if _spalte_fest(spalte, zeile_von, zeile_bis):
			neu = (spalte + 1) * BLOCK + BREITE / 2.0
			geschwindigkeit.x = 0.0
	position.x = neu


func _bewegen_y(dy: float) -> void:
	if dy == 0.0:
		return
	var neu := position.y + dy
	var spalte_von := floori((position.x - BREITE / 2.0) / BLOCK)
	var spalte_bis := floori((position.x + BREITE / 2.0 - EPSILON) / BLOCK)
	if dy > 0.0:
		# Nur Zeilen prüfen, in die die Füße neu eintauchen: so trägt eine Plattform nur von oben.
		var zeile_alt := floori((position.y - EPSILON) / BLOCK)
		var zeile_neu := floori((neu - EPSILON) / BLOCK)
		for zeile: int in range(zeile_alt + 1, zeile_neu + 1):
			if _zeile_traegt(zeile, spalte_von, spalte_bis):
				neu = zeile * BLOCK
				geschwindigkeit.y = 0.0
				break
	else:
		var kopf_alt := floori((position.y - HOEHE) / BLOCK)
		var kopf_neu := floori((neu - HOEHE) / BLOCK)
		if kopf_neu < kopf_alt:
			for spalte: int in range(spalte_von, spalte_bis + 1):
				if raster.art_bei(spalte, kopf_neu) == Raster.Art.FEST:
					neu = (kopf_neu + 1) * BLOCK + HOEHE
					geschwindigkeit.y = 0.0
					rest_halten = 0.0
					an_decke = true
					break
	position.y = neu


func _beruehrungen_pruefen() -> void:
	var spalte_von := floori((position.x - BREITE / 2.0) / BLOCK)
	var spalte_bis := floori((position.x + BREITE / 2.0 - EPSILON) / BLOCK)
	var zeile_unter := floori((position.y + EPSILON) / BLOCK)
	var genau_auf_kante := absf(position.y - zeile_unter * BLOCK) < 0.01
	auf_boden = (
		geschwindigkeit.y >= 0.0
		and genau_auf_kante
		and _zeile_traegt(zeile_unter, spalte_von, spalte_bis)
	)

	var zeile_von := floori((position.y - HOEHE) / BLOCK)
	var zeile_bis := floori((position.y - EPSILON) / BLOCK)
	var rechts := floori((position.x + BREITE / 2.0 + 0.01) / BLOCK)
	var links := floori((position.x - BREITE / 2.0 - 0.01) / BLOCK)
	var wand_rechts := _spalte_fest(rechts, zeile_von, zeile_bis)
	var wand_links := _spalte_fest(links, zeile_von, zeile_bis)
	if wand_rechts and (not wand_links or richtung >= 0):
		wand_seite = 1
	elif wand_links:
		wand_seite = -1
	else:
		wand_seite = 0


func _spalte_fest(spalte: int, zeile_von: int, zeile_bis: int) -> bool:
	for zeile: int in range(zeile_von, zeile_bis + 1):
		if raster.art_bei(spalte, zeile) == Raster.Art.FEST:
			return true
	return false


func _zeile_traegt(zeile: int, spalte_von: int, spalte_bis: int) -> bool:
	for spalte: int in range(spalte_von, spalte_bis + 1):
		var art := raster.art_bei(spalte, zeile)
		if art == Raster.Art.FEST:
			return true
		if art == Raster.Art.PLATTFORM and rest_durchfallen <= 0.0:
			return true
	return false


func _steht_nur_auf_plattform() -> bool:
	var zeile := floori((position.y + EPSILON) / BLOCK)
	var spalte_von := floori((position.x - BREITE / 2.0) / BLOCK)
	var spalte_bis := floori((position.x + BREITE / 2.0 - EPSILON) / BLOCK)
	for spalte: int in range(spalte_von, spalte_bis + 1):
		if raster.art_bei(spalte, zeile) == Raster.Art.FEST:
			return false
	return true


## Kopf über der Wand frei, Füße noch an der Wand: die Oberkante ist erreicht.
func _kante_erreicht(seite: int) -> bool:
	var x := position.x + seite * (BREITE / 2.0 + 0.01)
	var spalte := floori(x / BLOCK)
	var kopf := floori((position.y - HOEHE + 1.0) / BLOCK)
	var fuesse := floori((position.y - 1.0) / BLOCK)
	return (
		raster.art_bei(spalte, kopf) != Raster.Art.FEST
		and raster.art_bei(spalte, fuesse) == Raster.Art.FEST
	)


func _draw() -> void:
	var farbe := Color(0.75, 0.78, 0.85)
	match zustand:
		"Steigen":
			farbe = Color(0.55, 0.8, 1.0)
		"Fallen":
			farbe = Color(0.4, 0.55, 0.95)
		"Wand":
			farbe = Color(1.0, 0.75, 0.3)
		"Kanten-Flip":
			farbe = Color(1.0, 0.4, 0.8)
	draw_rect(Rect2(-BREITE / 2.0, -HOEHE, BREITE, HOEHE), farbe)
	# Visier zeigt die Blickrichtung.
	draw_rect(Rect2(1.0 if blick > 0 else -5.0, -15.0, 4.0, 2.0), Color(0.1, 0.1, 0.15))
